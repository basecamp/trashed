require 'barnes/consts'

module Barnes
  class Periodic
    def initialize(reporter, sample_rate = 1, panels = [])
      @reporter = reporter
      @reporter.sample_rate = sample_rate

      # compute interval based on a 60s reporting phase.
      @interval = sample_rate * 60.0
      @panels = panels

      @thread = Thread.new {
        Thread.current[:barnes_state] = {}

        @panels.each do |panel|
          panel.start! Thread.current[:barnes_state]
        end

        loop do
          begin
            sleep @interval

            # read the current values
            env = {
              STATE => Thread.current[:barnes_state],
              COUNTERS => {},
              GAUGES => {}
            }

            @panels.each do |panel|
              panel.instrument! env[STATE], env[COUNTERS], env[GAUGES]
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
