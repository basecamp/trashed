module Trashed
  module Instruments
    class Stopwatch
      def initialize(timepiece = Timepiece)
        @timepiece = timepiece
        @has_cpu_time = timepiece.respond_to?(:cpu)
      end

      def start(state)
        state[:'Time.wall'] = @timepiece.wall
        state[:'Time.cpu']  = @timepiece.cpu if @has_cpu_time
      end

      def measure(state, timings, gauges)
        wall_elapsed = @timepiece.wall - state.delete(:'Time.wall')
        timings[:'Time.wall'] = wall_elapsed
        if @has_cpu_time
          cpu_elapsed = @timepiece.cpu - state.delete(:'Time.cpu')
          timings[:'Time.cpu'] = cpu_elapsed
          timings[:'Time.idle'] = wall_elapsed - cpu_elapsed
        end
      end
    end

    module Timepiece
      def self.wall
        (::Time.now.to_f * 1000).to_i
      end

      # Ruby 2.1+
      if Process.respond_to?(:clock_gettime)
        def self.cpu
          Process.clock_gettime Process::CLOCK_PROCESS_CPUTIME_ID, :millisecond
        end

      # ruby-prof installed
      elsif defined? RubyProf::Measure::ProcessTime
        def self.cpu
          (RubyProf::Measure::Process.measure * 1000).to_i
        end
      end
    end
  end
end
