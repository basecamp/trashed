module Barnes
  module Instruments
    class RubyGC
      COUNTERS = {
        :count => :'GC.count',
        :major_gc_count => :'GC.major_count',
        :minor_gc_count => :'GC.minor_gc_count' }

      GAUGE_COUNTERS = {}

      # Detect Ruby 2.1 vs 2.2 GC.stat naming
      begin
        GC.stat :total_allocated_objects
      rescue ArgumentError
        GAUGE_COUNTERS.update \
          :total_allocated_object => :'GC.total_allocated_objects',
          :total_freed_object => :'GC.total_freed_objects'
      else
        GAUGE_COUNTERS.update \
          :total_allocated_objects => :'GC.total_allocated_objects',
          :total_freed_objects => :'GC.total_freed_objects'
      end

      def initialize(sample_rate)
        # see doc.gb for an explanation of sample_rate in this context.
        @sample_rate = sample_rate
      end

      def start!(state)
        state[:ruby_gc] = GC.stat
      end

      def instrument!(state, counters, gauges)
        last = state[:ruby_gc]
        cur = state[:ruby_gc] = GC.stat

        COUNTERS.each do |stat, metric|
          counters[metric] = cur[stat] - last[stat] if cur.include? stat
        end

        # special treatment gauges
        GAUGE_COUNTERS.each do |stat, metric|
          if cur.include? stat
            val = cur[stat] - last[stat] if cur.include? stat
            gauges[metric] = val * (1/@sample_rate)
          end
        end

        # the rest of the gauges
        cur.each do |k, v|
          unless GAUGE_COUNTERS.include? k
            gauges[:"GC.#{k}"] = v
          end
        end
      end
    end
  end
end
