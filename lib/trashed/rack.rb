module Trashed
  module Rack
    class MeasureResourceUsage
      def initialize(app, options = {})
        @app = app
        @debug, @logger, @statsd, @sample_rate = options.values_at(:debug, :logger, :statsd, :sample_rate)
        @sample_rate ||= 0.1
      end

      def call(env)
        response = nil
        instrument { response = @app.call(env) }
        response
      end

      def instrument(&block)
        change = env['trashed.change'] = ResourceUsage.instrument(&block)
        usage  = env['trashed.usage']  = ResourceUsage.gauge
        record change, usage
      end

      def record(change, usage)
        record_logger change, usage if @logger
        record_statsd change, usage if @statsd
      end

      def record_logger(change, usage)
        @logger.info "Rack handled in %dms (GC runs: %d)" % change.values_at('Time.wall', 'GC.count')
        record_debug_logger change, usage if @debug
      end

      def record_debug_logger(change, usage)
        @logger.debug "Changes: #{change.to_yaml}"
        @logger.debug "Usage: #{usage.to_yaml}"
      end

      def record_statsd(change, usage)
        record_statsd_timing change
        record_statsd_timing usage
      end

      def record_statsd_timing(data)
        data.each { |name, value| @statsd.timing "Performance.#{name}", value, @sample_rate }
      end
    end
  end
end
