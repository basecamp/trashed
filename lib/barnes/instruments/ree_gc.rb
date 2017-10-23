module Barnes
  module Instruments
    class Ruby18GC
      def initialize
        GC.enable_stats
      end

      def start!(state)
        state[:ruby18_gc] = current
      end

      def instrument!(state, counters, gauges)
        last = state[:ruby18_gc]
        cur = state[:ruby18_gc] = current

        counters.update \
          :'GC.count'             => cur[:gc_count] - before[:gc_count],
          :'GC.time'              => cur[:gc_time] - before[:gc_time],
          :'GC.memory'            => cur[:gc_memory] - before[:gc_memory],
          :'GC.allocated_objects' => cur[:objects] - before[:objects]

        gauges[:'Objects.live'] = ObjectSpace.live_objects
        gauges[:'GC.growth'] = GC.growth
      end

      private def current
        {
          :objects   => ObjectSpace.allocated_objects,
          :gc_count  => GC.collections,
          :gc_time   => GC.time,
          :gc_memory => GC.allocated_size
        }
      end
    end
  end
end
