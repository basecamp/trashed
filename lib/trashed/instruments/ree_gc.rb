module Trashed
  module Instruments
    class Ruby18GC
      def initialize
        GC.enable_stats
      end

      def start(state, timings, gauges)
        state[:ruby18_gc] = {
          :objects   => ObjectSpace.allocated_objects,
          :gc_count  => GC.collections,
          :gc_time   => GC.time,
          :gc_memory => GC.allocated_size }
      end

      def measure(state, timings, gauges)
        before = state[:ruby18_gc]

        timings.update \
          :'GC.count'             => GC.collections - before[:gc_count],
          :'GC.time'              => (GC.time - before[:gc_time]) / 1000.0,
          :'GC.memory'            => GC.allocated_size - before[:gc_memory],
          :'GC.allocated_objects' => ObjectSpace.allocated_objects - before[:objects]

        gauges << [ :'Objects.live',  ObjectSpace.live_objects ]
        gauges << [ :'GC.growth',     GC.growth ]
      end
    end
  end
end
