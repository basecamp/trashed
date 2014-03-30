require 'trashed/resource_usage'

module Trashed
  class Rack
    STATE, TIMINGS, GAUGES = 'trashed.state', 'trashed.timings', 'trashed.gauges'

    def initialize(app, reporter, options = {})
      @reporter = reporter
      @meters = Array(options.fetch(:meters, [ResourceUsage]))
      @logger, @statsd, @sample_rate = options.values_at(:logger, :statsd_instance, :sample_rate)
      @sample_rate ||= 1.0

      @request_namespaces = options[:statsd_request_namespaces]
      @sampler_namespaces = options[:statsd_sampler_namespaces]

      # Wrap the app up in the meters.
      @app = build_instrumented_app(app, @meters)
    end

    def call(env)
      env[STATE]   = {}
      env[TIMINGS] = {}
      env[GAUGES]  = []

      @app.call(env).tap { @reporter.report env }
    end

    private
    def build_instrumented_app(app, meters)
      meters.inject app do |wrapped, meter|
        lambda do |env|
          meter.instrument! env[STATE], env[TIMINGS], env[GAUGES] do
            wrapped.call env
          end
        end
      end
    end
  end
end
