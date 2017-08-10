require 'trashed/resource_usage'
require 'trashed/consts'

module Trashed
  class Periodic
    def initialize(reporter, interval = 10, options = {})
      @reporter = reporter
      @interval = interval
      @meters = Array(options.fetch(:meters, [ResourceUsage]))
      @thread = Thread.new {
        Thread.current[:trashed_state] = {}
        loop do
          begin
            sleep @interval

            env = {
              STATE => { :persistent => Thread.current[:trashed_state] },
              COUNTERS => {},
              GAUGES => []
            }

            @meters.each do |meter|
              puts "Meter #{meter}\n"
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
