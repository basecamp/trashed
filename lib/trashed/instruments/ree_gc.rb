module Trashed
  module Instruments
    class Ruby18GC
      def initialize
        GC.enable_stats
      end

      def start(state)
        state.update \
          :'Objects.total' => ObjectSpace.allocated_objects,
          :'GC.count'      => GC.collections,
          :'GC.elapsed'    => GC.time,
          :'GC.memory'     => GC.allocated_size
      end

      def measure(state, timings, gauges)
        timings.update \
          :'Objects.total' => ObjectSpace.allocated_objects - state[:'Objects.total'],
          :'GC.count'      => GC.collections - state[:'GC.count'],
          :'GC.elapsed'    => GC.time - state[:'GC.elapsed'],
          :'GC.memory'     => GC.allocated_size - state[:'GC.memory']

        gauges << [ :'Objects.live',  ObjectSpace.live_objects ]
        gauges << [ :'GC.growth',     GC.growth ]
      end
    end
  end
end
