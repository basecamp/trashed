require 'trashed/rack'

module Trashed
  class Reporter
    attr_accessor :logger, :statsd
    attr_accessor :timing_sample_rate, :gauge_sample_rate
    attr_accessor :timing_dimensions, :gauge_dimensions

    DEFAULT_DIMENSIONS = [ :All ]

    def initialize
      @logger = nil
      @statsd = nil
      @timing_sample_rate = 0.1
      @gauge_sample_rate = 0.05
      @timing_dimensions  = ->(env) { DEFAULT_DIMENSIONS }
      @gauge_dimensions   = ->(env) { DEFAULT_DIMENSIONS }
    end

    def report(env)
      report_logger env if @logger
      report_statsd env if @statsd
    end

    def report_logger(env)
      timings = env[Trashed::Rack::TIMINGS]
      parts = []

      elapsed = '%.2fms' % timings[:'Time.wall']
      if timings[:'Time.pct.cpu']
        elapsed << ' (%.1f%% cpu, %.1f%% idle)' % timings.values_at(:'Time.pct.cpu', :'Time.pct.idle').map(&:to_i)
      end
      parts << elapsed

      obj = timings[:'GC.allocated_objects'].to_i
      parts << '%d objects' % obj unless obj.zero?

      if gcs = timings[:'GC.count'].to_i
        gc = '%d GCs' % gcs
        unless gcs.zero?
          if timings.include?(:'GC.major_count')
            gc << ' (%d major, %d minor)' % timings.values_at(:'GC.major_count', :'GC.minor_count').map(&:to_i)
          end
          if timings.include?(:'GC.time')
            gc << ' took %.2fms' % timings[:'GC.time']
          end
        end
        parts << gc
      end

      oobgcs = timings[:'OOBGC.count'].to_i
      if !oobgcs.zero?
        oobgc = 'Avoided %d OOB GCs' % oobgcs
        if timings[:'OOBGC.major_count']
          oobgc << ' (%d major, %d minor, %d sweep)' % timings.values_at(:'OOBGC.major_count', :'OOBGC.minor_count', :'OOBGC.sweep_count').map(&:to_i)
        end
        if timings[:'OOBGC.time']
          oobgc << ' saving %.2fms' % timings[:'OOBGC.time']
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
        send_to_statsd statsd, :timing, @timing_sample_rate, env[Trashed::Rack::TIMINGS], :'Rack.Request', @timing_dimensions.call(env)
        send_to_statsd statsd, :timing, @gauge_sample_rate,  env[Trashed::Rack::GAUGES],  :'Rack.Server',  @gauge_dimensions.call(env)
      end
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
end
