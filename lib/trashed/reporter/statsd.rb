module Trashed
  module Reporter
    class Statsd
      require 'statsd'

      attr_accessor :statsd
      attr_accessor :timing_sample_rate, :gauge_sample_rate
      attr_accessor :timing_dimensions, :gauge_dimensions

      DEFAULT_DIMENSIONS = [ :All ]

      def initialize(statsd = nil)
        @statsd = statsd
        @timing_sample_rate = 0.1
        @gauge_sample_rate = 0.05
        @timing_dimensions  = ->(env) { DEFAULT_DIMENSIONS }
        @gauge_dimensions   = ->(env) { DEFAULT_DIMENSIONS }
      end

      def report(env)
        return unless @statsd

        method = @statsd.respond_to?(:easy) ? :easy : :batch
        @statsd.send(method) do |statsd|
          send_to_statsd statsd, :timing, @timing_sample_rate, env[Trashed::Rack::TIMINGS], :'Rack.Request', @timing_dimensions.call(env)
          send_to_statsd statsd, :timing, @gauge_sample_rate,  env[Trashed::Rack::GAUGES],  :'Rack.Server',  @gauge_dimensions.call(env)
        end
      end

      def send_to_statsd(statsd, method, sample_rate, measurements, namespace, dimensions)
        measurements.each do |metric, value|
          case value
          when Array
            value.each do |v|
              send_to_statsd statsd, method, sample_rate, { metric => v }, namespace, dimensions
            end
          when Numeric
            Array(dimensions || :All).each do |dimension|
              statsd.send method, :"#{namespace}.#{dimension}.#{metric}", value, sample_rate
            end
          end
        end
      end
    end
  end
end
