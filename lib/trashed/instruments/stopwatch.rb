module Trashed
  module Instruments
    class Stopwatch
      def initialize(timepiece = Timepiece)
        @timepiece = timepiece
        @has_cpu_time = timepiece.respond_to?(:cpu)
      end

      def start(state, timings, gauges)
        state[:stopwatch_wall] = @timepiece.wall
        state[:stopwatch_cpu]  = @timepiece.cpu if @has_cpu_time
      end

      def measure(state, timings, gauges)
        wall_elapsed = @timepiece.wall - state.delete(:stopwatch_wall)
        timings[:'Time.wall'] = wall_elapsed
        if @has_cpu_time
          cpu_elapsed = @timepiece.cpu - state.delete(:stopwatch_cpu)
          idle_elapsed = wall_elapsed - cpu_elapsed

          timings[:'Time.cpu']      = cpu_elapsed
          timings[:'Time.idle']     = idle_elapsed

          if wall_elapsed == 0
            timings[:'Time.pct.cpu']  = 0
            timings[:'Time.pct.idle'] = 0
          else
            timings[:'Time.pct.cpu']  = 100.0 * cpu_elapsed  / wall_elapsed
            timings[:'Time.pct.idle'] = 100.0 * idle_elapsed / wall_elapsed
          end
        end
      end
    end

    module Timepiece
      def self.wall
        ::Time.now.to_f * 1000
      end

      # Ruby 2.1+
      if Process.respond_to?(:clock_gettime)
        def self.cpu
          Process.clock_gettime Process::CLOCK_PROCESS_CPUTIME_ID, :float_millisecond
        end

      # ruby-prof installed
      elsif defined? RubyProf::Measure::ProcessTime
        def self.cpu
          RubyProf::Measure::Process.measure * 1000
        end
      end
    end
  end
end
