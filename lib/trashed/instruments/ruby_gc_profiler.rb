module Trashed
  module Instruments
    class RubyGCProfiler
      def initialize
        @has_raw_data = GC::Profiler.respond_to?(:raw_data)
      end

      def start(state)
        GC::Profiler.enable
        GC::Profiler.clear
      end

      def measure(state, timings, gauges)
        timings[:'GC.time'] = GC::Profiler.total_time

        if @has_raw_data
          GC::Profiler.raw_data.each do |data|
            gauges.concat data.map { |k, v| [ :"GC.Profiler.#{k}", v ] }
          end
        end

        GC::Profiler.disable
        GC::Profiler.clear
      end
    end
  end
end
