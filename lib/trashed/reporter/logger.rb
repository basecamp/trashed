module Trashed
  module Reporter
    class Logger
      attr_accessor :logger

      def initialize(logger = nil)
        @logger = logger
      end

      def report(env)
        return unless @logger

        timings = env[Trashed::Rack::TIMINGS]
        parts = []

        elapsed = '%.2fms' % timings[:'Time.wall']
        if timings[:'Time.pct.cpu']
          elapsed << ' (%.1f%% cpu, %.1f%% idle)' % timings.values_at(:'Time.pct.cpu', :'Time.pct.idle')
        end
        parts << elapsed

        obj = timings[:'GC.allocated_objects'].to_i
        parts << '%d objects' % obj unless obj.zero?

        if gcs = timings[:'GC.count'].to_i
          gc = '%d GCs' % gcs
          unless gcs.zero?
            if timings.include?(:'GC.major_count')
              gc << ' (%d major, %d minor)' % timings.values_at(:'GC.major_count', :'GC.minor_count').map(&:to_i)
            end
            if timings.include?(:'GC.time')
              gc << ' took %.2fms' % timings[:'GC.time']
            end
          end
          parts << gc
        end

        oobgcs = timings[:'OOBGC.count'].to_i
        if !oobgcs.zero?
          oobgc = 'Avoided %d OOB GCs' % oobgcs
          if timings[:'OOBGC.major_count']
            oobgc << ' (%d major, %d minor, %d sweep)' % timings.values_at(:'OOBGC.major_count', :'OOBGC.minor_count', :'OOBGC.sweep_count').map(&:to_i)
          end
          if timings[:'OOBGC.time']
            oobgc << ' saving %.2fms' % timings[:'OOBGC.time']
          end
          parts << oobgc
        end

        message = "Rack handled in #{parts * '. '}."

        if @logger.respond_to?(:tagged) && env.include?('trashed.logger.tags')
          @logger.tagged env['trashed.logger.tags'] do
            @logger.info message
          end
        else
          @logger.info message
        end
      end
    end
  end
end
