require 'trashed/resource_usage'
require 'trashed/consts'

module Trashed
  class Rack

    def initialize(app, reporter, options = {})
      @reporter = reporter
      @meters = Array(options.fetch(:meters, [ResourceUsage]))
      @app = build_instrumented_app(app, @meters)
    end

    def call(env)
      env[STATE]   = { :persistent => persistent_thread_state }
      env[COUNTERS] = {}
      env[GAUGES]  = []

      @app.call(env).tap { @reporter.report env }
    end

    private
    def persistent_thread_state
      Thread.current[:trashed_rack_state] ||= {}
    end

    def build_instrumented_app(app, meters)
      meters.inject app do |wrapped, meter|
        lambda do |env|
          meter.instrument! env[STATE], env[COUNTERS], env[GAUGES] do
            wrapped.call env
          end
        end
      end
    end
  end
end
