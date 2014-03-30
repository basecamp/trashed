module Trashed
  module Instruments
    class RubyGC
      def start(state, timings, gauges)
        state[:ruby_gc] = GC.stat
      end

      MEASUREMENTS = {
        :count => :'GC.count',
        :major_gc_count => :'GC.major_count',
        :minor_gc_count => :'GC.minor_gc_count',
        :total_allocated_object => :'GC.allocated_objects',
        :total_freed_object => :'GC.freed_objects'
      }

      def measure(state, timings, gauges)
        gc = GC.stat
        before = state[:ruby_gc]

        MEASUREMENTS.each do |stat, metric|
          timings[metric] = gc[stat] - before[stat] if gc.include? stat
        end

        gauges.concat gc.map { |k, v| [ :"GC.#{k}", v ] }
      end
    end
  end
end
