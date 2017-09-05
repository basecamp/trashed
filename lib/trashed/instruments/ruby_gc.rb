module Trashed
  module Instruments
    class RubyGC
      def start(state, counters, gauges)
        state[:ruby_gc] = GC.stat
      end

      MEASUREMENTS = {
        :count => :'GC.count',
        :major_gc_count => :'GC.major_count',
        :minor_gc_count => :'GC.minor_gc_count' }

      # Detect Ruby 2.1 vs 2.2 GC.stat naming
      begin
        GC.stat :total_allocated_objects
      rescue ArgumentError
        MEASUREMENTS.update \
          :total_allocated_object => :'GC.allocated_objects',
          :total_freed_object => :'GC.freed_objects'
      else
        MEASUREMENTS.update \
          :total_allocated_objects => :'GC.allocated_objects',
          :total_freed_objects => :'GC.freed_objects'
      end

      def measure(state, counters, gauges)
        gc = GC.stat
        before = state[:ruby_gc]

        MEASUREMENTS.each do |stat, metric|
          counters[metric] = gc[stat] - before[stat] if gc.include? stat
        end

        gauges.concat gc.map { |k, v| [ :"GC.#{k}", v ] }
      end
    end
  end
end
