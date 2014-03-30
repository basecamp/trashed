require 'trashed/resource_usage'

module Trashed
  class Rack
    STATE, TIMINGS, GAUGES = 'trashed.state', 'trashed.timings', 'trashed.gauges'

    def initialize(app, reporter, options = {})
      @reporter = reporter
      @meters = Array(options.fetch(:meters, [ResourceUsage]))
      @app = build_sampled_instrumented_app(app, @meters)
    end

    def call(env)
      env[STATE]   = { :persistent => persistent_thread_state }
      env[TIMINGS] = {}
      env[GAUGES]  = []

      @app.call(env).tap { @reporter.report env }
    end

    private
    def persistent_thread_state
      Thread.current[:trashed_rack_state] ||= {}
    end

    def build_sampled_instrumented_app(app, meters)
      build_sampled_app app, build_instrumented_app(app, meters)
    end

    def build_sampled_app(app, instrumented)
      lambda do |env|
        if @reporter.sample? env
          instrumented.call env
        else
          app.call env
        end
      end
    end

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
