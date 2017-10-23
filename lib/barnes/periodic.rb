require 'barnes/consts'

module Barnes
  # The periodic class is used to send occasional metrics
  # to a reporting instance of `Barnes::Reporter` at a semi-regular
  # rate.
  class Periodic
    def initialize(reporter:, sample_rate: 1, panels: [])
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
              STATE    => Thread.current[:barnes_state],
              COUNTERS => {},
              GAUGES   => {}
            }

            @panels.each do |panel|
              panel.instrument! env[STATE], env[COUNTERS], env[GAUGES]
            end
            @reporter.report env
          end
        end
      }
      @thread.abort_on_exception = true
    end

    def stop
      @thread.exit
    end
  end
end
