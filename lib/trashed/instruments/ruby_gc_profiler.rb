module Trashed
  module Instruments
    class RubyGCProfiler
      # Captures out-of-band GC time and stats.
      def start(state, timings, gauges)
        GC::Profiler.enable
        measure state, timings, gauges, :OOBGC
      end

      # Captures in-band GC time and stats.
      def measure(state, timings, gauges, captured = :GC)
        timings[:"#{captured}.time"] ||= 1000 * GC::Profiler.total_time

        if GC::Profiler.respond_to? :raw_data
          timings[:"#{captured}.count"] ||= GC::Profiler.raw_data.size
          timings[:'GC.interval'] = GC::Profiler.raw_data.map { |data| 1000 * data[:GC_INVOKE_TIME] }
        end

        # Clears .total_time and .raw_data
        GC::Profiler.clear
      end
    end
  end
end
