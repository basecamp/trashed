module Barnes
  class Panel
    def initialize
      @instruments = []
    end

    # Add an instrument to the Panel
    def instrument(instrument)
      @instruments << instrument
    end

    # Initialize the state of each instrument in the panel.
    def start!(state)
      @instruments.each do |ins|
        ins.start! state if ins.respond_to?(:start!)
      end
    end

    # Read the values of each instrument into counter_readings,
    # and gauge_readings. May have side effects on all arguments.
    def instrument!(state, counter_readings, gauge_readings)
      @instruments.each do |ins|
        ins.instrument! state, counter_readings, gauge_readings
      end
    end
  end
end
