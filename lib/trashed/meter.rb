module Trashed
  class Meter
    attr_reader :instruments

    def initialize
      @instruments = []
      @needs_start = []
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
      @instruments << instrument
      @needs_start << instrument if instrument.respond_to?(:start)
    end

    def instrument!(state, timings, gauges)
      @needs_start.each { |i| i.start state }
      yield.tap do
        @instruments.reverse_each { |i| i.measure state, timings, gauges }
      end
    end

    class ChangeInstrument
      def initialize(name, probe)
        @name, @probe = name, probe
      end

      def start(state)
        state[@name] = @probe.call
      end

      def measure(state, timings, gauges)
        timings[@name] = @probe.call - state[@name]
      end
    end

    class GaugeInstrument
      def initialize(name, probe)
        @name, @probe = name, probe
      end

      def measure(state, timings, gauges)
        gauges << [ @name, @probe.call ]
      end
    end
  end
end
