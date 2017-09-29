require 'barnes/resource_usage'
require 'barnes/consts'

module Barnes
  class Periodic
    def initialize(reporter, interval = 10, options = {})
      @reporter = reporter
      @interval = interval
      @meters = Array(options.fetch(:meters, [ResourceUsage]))
      @thread = Thread.new {
        Thread.current[:barnes_state] = {}
        loop do
          begin
            sleep @interval

            env = {
              STATE => { :persistent => Thread.current[:barnes_state] },
              COUNTERS => {},
              GAUGES => []
            }

            @meters.each do |meter|
              meter.instrument! env[STATE], env[COUNTERS], env[GAUGES] do
              end
            end

            @reporter.report env
          rescue => e
            # TODO: do something better here...
            puts e.backtrace.join "\n"
          end
        end
      }
    end

    def stop
      @thread.exit
    end
  end
end
