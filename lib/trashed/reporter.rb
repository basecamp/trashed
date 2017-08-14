require 'trashed/rack'

module Trashed
  class Reporter
    attr_accessor :logger, :statsd
    attr_accessor :counter_sample_rate, :gauge_sample_rate
    attr_accessor :counter_dimensions, :gauge_dimensions

    DEFAULT_DIMENSIONS = [ :All ]

    def initialize
      @logger = nil
      @statsd = nil
      @counter_sample_rate = 1.0
      @gauge_sample_rate = 1.0
      @counter_dimensions  = lambda { |env| DEFAULT_DIMENSIONS }
      @gauge_dimensions   = lambda { |env| DEFAULT_DIMENSIONS }
    end

    def report(env)
      report_logger env if @logger
      report_statsd env if @statsd
    end

    def report_logger(env)
      raise "must implement interface"
    end

    def report_statsd(env)
      raise "must implement interface"
    end

    def send_to_statsd(statsd, method, sample_rate, measurements, namespace, dimensions)
      measurements.each do |metric, value|
        case value
        when Array
          value.each do |v|
            send_to_statsd statsd, method, sample_rate, { metric => v }, namespace, dimensions
          end
        when Numeric
          Array(dimensions || :All).each do |dimension|
            statsd.send method, :"#{namespace}.#{dimension}.#{metric}", value, sample_rate
          end
        end
      end
    end
  end

  class RackReporter < Reporter

    def initialize
      super
      @counter_sample_rate = 0.1
      @gauge_sample_rate = 0.05
    end

    def report_logger(env)
      counters = env[Trashed::COUNTERS]
      parts = []

      elapsed = '%.2fms' % counters[:'Time.wall']
      if counters[:'Time.pct.cpu']
        elapsed << ' (%.1f%% cpu, %.1f%% idle)' % counters.values_at(:'Time.pct.cpu', :'Time.pct.idle')
      end
      parts << elapsed

      obj = counters[:'GC.allocated_objects'].to_i
      parts << '%d objects' % obj unless obj.zero?

      if gcs = counters[:'GC.count'].to_i
        gc = '%d GCs' % gcs
        unless gcs.zero?
          if counters.include?(:'GC.major_count')
            gc << ' (%d major, %d minor)' % counters.values_at(:'GC.major_count', :'GC.minor_count').map(&:to_i)
          end
          if counters.include?(:'GC.time')
            gc << ' took %.2fms' % counters[:'GC.time']
          end
        end
        parts << gc
      end

      oobgcs = counters[:'OOBGC.count'].to_i
      if !oobgcs.zero?
        oobgc = 'Avoided %d OOB GCs' % oobgcs
        if counters[:'OOBGC.major_count']
          oobgc << ' (%d major, %d minor, %d sweep)' % counters.values_at(:'OOBGC.major_count', :'OOBGC.minor_count', :'OOBGC.sweep_count').map(&:to_i)
        end
        if counters[:'OOBGC.time']
          oobgc << ' saving %.2fms' % counters[:'OOBGC.time']
        end
        parts << oobgc
      end

      message = "Rack handled in #{parts * '. '}."

      if @logger.respond_to?(:tagged) && env.include?('trashed.logger.tags')
        @logger.tagged env['trashed.logger.tags'] do
          @logger.info message
        end
      else
        @logger.info message
      end
    end

    def report_statsd(env)
      method = @statsd.respond_to?(:easy) ? :easy : :batch
      @statsd.send(method) do |statsd|
        # We emit the counters as timings to take advantage of statsd
        # aggregations, min, max, etc.
        send_to_statsd statsd, :timing, @counter_sample_rate, env[Trashed::COUNTERS], :'Rack.Request', @counter_dimensions.call(env)
      end
    end
  end

  class PeriodicReporter < Reporter

    def report_statsd(env)
      method = @statsd.respond_to?(:easy) ? :easy : :batch
      @statsd.send(method) do |statsd|
        send_to_statsd statsd, :count, @counter_sample_rate, env[Trashed::COUNTERS], :'Rack.Server', @counter_dimensions.call(env)
        send_to_statsd statsd, :gauge, @gauge_sample_rate, env[Trashed::GAUGES], :'Rack.Server', @gauge_dimensions.call(env)
      end
    end
  end
end
