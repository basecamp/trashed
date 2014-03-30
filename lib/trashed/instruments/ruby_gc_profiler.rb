module Trashed
  module Instruments
    class RubyGCProfiler
      def initialize
        @has_raw_data = GC::Profiler.respond_to?(:raw_data)
      end

      # Captures out-of-band GC time and stats.
      def start(state, timings, gauges)
        GC::Profiler.enable
        measure state, timings, gauges, :OOBGC
      end

      # Captures in-band GC time and stats.
      def measure(state, timings, gauges, captured = :GC)
        timings[:"#{captured}.time"] ||= GC::Profiler.total_time

        if @has_raw_data
          timings[:"#{captured}.count"] ||= GC::Profiler.raw_data.size

          timings[:'GC.interval'] = GC::Profiler.raw_data.map { |data| data[:GC_INVOKE_TIME] }

          GC::Profiler.raw_data.each do |data|
            gauges.concat data.map { |k, v| [ :"GC.Profiler.#{k}", v ] }
          end
        end

        GC::Profiler.clear
      end
    end
  end
end
