module Trashed
  class Meter
    attr_reader :instruments

    def initialize
      @counters = []
      @gauges = []
    end

    # Counters increase, so we measure before/after differences.
    # Time elapsed, memory growth, objects allocated, etc.
    def counts(name, &block)
      instrument ChangeInstrument.new(name, block)
    end

    # Gauges measure point-in-time values.
    # Heap size, live objects, GC count, etc.
    def gauges(name, &block)
      instrument GaugeInstrument.new(name, block)
    end

    def instrument(instrument)
      if instrument.respond_to?(:start)
        @counters << instrument
      else
        @gauges << instrument
      end
    end

    def instrument!(state, counters, gauges)
      @counters.each { |i| i.start state, counters,  gauges }
      yield.tap do
        @counters.reverse_each { |i| i.measure state, counters, gauges }
        @gauges.each { |i| i.measure state, counters, gauges }
      end
    end

    class ChangeInstrument
      def initialize(name, probe)
        @name, @probe = name, probe
      end

      def start(state, counters, gauges)
        state[@name] = @probe.call
      end

      def measure(state, counters, gauges)
        counters[@name] = @probe.call - state[@name]
      end
    end

    class GaugeInstrument
      def initialize(name, probe)
        @name, @probe = name, probe
      end

      def measure(state, counters, gauges)
        gauges << [ @name, @probe.call ]
      end
    end
  end
end
