module Trashed
  module Instruments
    class Ruby19GC
      def start(state)
        gc = GC.stat
        state[:'GC.count'] = gc[:count]
      end

      def measure(state, timings, gauges)
        gc = GC.stat
        timings[:'GC.count'] = gc[:count] - state.delete(:'GC.count')
        gauges.concat gc.map { |k, v| [ :"GC.#{k}", v ] }
      end
    end
  end
end
