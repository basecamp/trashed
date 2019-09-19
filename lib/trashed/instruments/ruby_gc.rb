module Trashed
  module Instruments
    class RubyGC
      def start(state, timings, gauges)
        state[:ruby_gc] = GC.stat
      end

      MEASUREMENTS = {
        :count => :'GC.count'
      }

      RUBY_2X_MEASUREMENTS = {
        :major_gc_count => :'GC.major_count',
        :minor_gc_count => :'GC.minor_gc_count'
      }

      # Detect Ruby 1.9, 2.1 or 2.2 GC.stat naming
      begin
        GC.stat :total_allocated_objects
      rescue TypeError
        # Ruby 1.9, nothing to do
      rescue ArgumentError
        # Ruby 2.1
        MEASUREMENTS.update \
          RUBY_2X_MEASUREMENTS.merge(
            :total_allocated_object => :'GC.allocated_objects',
            :total_freed_object => :'GC.freed_objects'
          )
      else
        # Ruby 2.2+
        MEASUREMENTS.update \
          RUBY_2X_MEASUREMENTS.merge(
            :total_allocated_objects => :'GC.allocated_objects',
            :total_freed_objects => :'GC.freed_objects'
          )
      end

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
