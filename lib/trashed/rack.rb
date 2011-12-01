module Trashed
  module Rack
    class MeasureResourceUsage
      def initialize(app, options = nil)
        @app, @options = app, options

        if @options
          @logger   = options[:logger]
          @debug    = options[:debug]
        end
      end

      def call(env)
        response = nil

        used = env['trashed.used'] = ResourceUsage.instrument { response = @app.call(env) }
        snap = env['trashed.snapshot'] = ResourceUsage.gauge

        if @logger
          if @debug
            @logger.debug "Used: #{used.to_yaml}"
            @logger.debug "Snapshot: #{snap.to_yaml}"
          else
            @logger.info "Rack handled in #{used['Time.wall']}ms (GC runs: #{used['GC.count']})"
          end
        end

        response
      end
    end
  end
end
