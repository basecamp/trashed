module Trashed
  module Rack
    # Rack middleware logs GC time, object allocation, and heap growth. Format:
    # [Trashed] Objects/Live: 389283 objects; GC/Malloc: 7377272 bytes; etc.
    class RequestLogger
      FORMAT = '%s: %d %s'

      def initialize(app, logger, metrics, format = FORMAT.dup)
        @app, @logger, @metrics, @format = app, logger, metrics, format
        check_availability
      end

      def call(env)
        measure { @app.call(env) }
      end

      private
        def measure
          # Copy metrics per request in case they're stateful.
          metrics = @metrics.map(&:dup)
          metrics.each(&:measure)

          response = yield

          measurements = metrics.map { |m| @format % [m.label, m.measure, m.units] }
          @logger.info "[Trashed] #{measurements * '; '}"

          response
        end

        def check_availability
          unless @metrics.respond_to?(:all?) && @metrics.all? { |m| m.respond_to?(:measure) }
            raise "Expected an array of metrics: #{@metrics.inspect}"
          end

          unavailable = @metrics.reject(&:available?)
          if unavailable.any?
            raise "[Trashed] #{unavailable.map(&:label).to_sentence} not available on this system"
          end
        end
    end
  end
end
