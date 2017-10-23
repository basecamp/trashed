module Barnes
  module Instruments
    class Stopwatch
      def initialize(timepiece = Timepiece)
        @timepiece = timepiece
        @has_cpu_time = timepiece.respond_to?(:cpu)
      end

      def start!(state)
        state[:stopwatch] = current
      end

      def instrument!(state, counters, gauges)
        last = state[:stopwatch]
        wall_elapsed = @timepiece.wall - last[:wall]
        counters[:'Time.wall'] = wall_elapsed

        if @has_cpu_time
          cpu_elapsed = @timepiece.cpu - last[:cpu]
          idle_elapsed = wall_elapsed - cpu_elapsed

          counters[:'Time.cpu']      = cpu_elapsed
          counters[:'Time.idle']     = idle_elapsed

          if wall_elapsed == 0
            counters[:'Time.pct.cpu']  = 0
            counters[:'Time.pct.idle'] = 0
          else
            counters[:'Time.pct.cpu']  = 100.0 * cpu_elapsed  / wall_elapsed
            counters[:'Time.pct.idle'] = 100.0 * idle_elapsed / wall_elapsed
          end
        end

        state[:stopwatch] = current
      end

      private def current
        state = {
          :wall => @timepiece.wall,
        }
        state[:cpu]  = @timepiece.cpu if @has_cpu_time
        state
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
