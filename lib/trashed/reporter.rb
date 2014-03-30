require 'trashed/rack'

module Trashed
  class Reporter
    attr_accessor :logger, :statsd, :sample_rate
    attr_accessor :timing_dimensions, :gauge_dimensions

    DEFAULT_DIMENSIONS = [ :All ]

    def initialize
      @logger = nil
      @statsd = nil
      @sample_rate = 1.0
      @timing_dimensions  = ->(env) { DEFAULT_DIMENSIONS }
      @gauge_dimensions   = ->(env) { DEFAULT_DIMENSIONS }
    end

    def report(env)
      report_logger env if @logger
      report_statsd env if @statsd
    end

    def report_logger(env)
      elapsed = env[Trashed::Rack::TIMINGS].assoc(:'Time.wall')
      gc_runs = env[Trashed::Rack::TIMINGS].assoc(:'GC.count')
      if elapsed && gc_runs
        @logger.info "Rack handled in %dms (GC runs: %d)" % [elapsed[1], gc_runs[1]]
      end
    end

    def report_statsd(env)
      @statsd.batch do |statsd|
        send_to_statsd statsd, :timing, env[Trashed::Rack::TIMINGS], :'Rack.Request', @timing_dimensions.call(env)
        send_to_statsd statsd, :gauge,  env[Trashed::Rack::GAUGES],  :'Rack.Server',  @gauge_dimensions.call(env)
      end
    end

    def send_to_statsd(statsd, method, measurements, namespace, dimensions)
      measurements.each do |metric, value|
        if value.is_a? Numeric
          Array(dimensions || :All).each do |dimension|
            statsd.send method, :"#{namespace}.#{dimension}.#{metric}", value, @sample_rate
          end
        end
      end
    end
  end
end
