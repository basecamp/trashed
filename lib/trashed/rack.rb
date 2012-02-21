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
        instrument(env) { response = @app.call(env) }
        response
      end

      def instrument(env, &block)
        change = ResourceUsage.instrument(&block)
        usage  = ResourceUsage.gauge
        record env, change, usage
      end

      def record(env, change, usage)
        record_env    env, change, usage
        record_logger env, change, usage if @logger
        record_statsd env, change, usage if @statsd
      end

      def record_env(env, change, usage)
        env['trashed.change'] = change
        env['trashed.usage']  = usage
      end

      def record_logger(env, change, usage)
        @logger.info "Rack handled in %dms (GC runs: %d)" % change.values_at('Time.wall', 'GC.count')
        record_debug_logger env, change, usage if @debug
      end

      def record_debug_logger(env, change, usage)
        @logger.debug "Changes: #{change.to_yaml}"
        @logger.debug "Usage: #{usage.to_yaml}"
      end

      def record_statsd(env, change, usage)
        record_statsd_timing change, :'Rack.Request'
        record_statsd_timing usage,  :Rack
      end

      def record_statsd_timing(data, namespace = nil)
        data.each do |name, value|
          name = "#{namespace}.#{name}" if namespace
          @statsd.timing name, value, @sample_rate
        end
      end
    end
  end
end
