module Trashed
  module Instruments
    class RubyGCProfiler
      # Captures out-of-band GC time and stats.
      def start(state, counters, gauges)
        GC::Profiler.enable
        measure state, counters, gauges, :OOBGC
      end

      # Captures in-band GC time and stats.
      def measure(state, counters, gauges, captured = :GC)
        counters[:"#{captured}.time"] ||= 1000 * GC::Profiler.total_time

        if GC::Profiler.respond_to? :raw_data
          counters[:"#{captured}.count"] ||= GC::Profiler.raw_data.size
          counters[:'GC.interval'] = GC::Profiler.raw_data.map { |data| 1000 * data[:GC_INVOKE_TIME] }
        end

        # Clears .total_time and .raw_data
        GC::Profiler.clear
      end
    end
  end
end
