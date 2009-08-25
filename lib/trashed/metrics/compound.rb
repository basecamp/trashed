module Trashed
  module Metrics
    # Bundle up multiple metrics
    class Compound
      class Measurement < Hash
        def -(other)
          inject(self.class.new) do |delta, (label, measurement)|
            delta[label] = measurement - other[label]
            delta
          end
        end
      end

      attr_reader :label, :metrics

      def initialize(label, metrics)
        unless metrics.respond_to?(:all?) && metrics.all? { |m| m.respond_to?(:measure) }
          raise "Expected an array of metrics: #{metrics.inspect}"
        end

        @label, @metrics = label.to_s, metrics
      end

      def units
        metrics.map(&:units)
      end

      def available?
        metrics.all?(&:available?)
      end

      def measure
        metrics.inject(Measurement.new) do |measurement, metric|
          measurement[metric.label] = metric.measure
          measurement
        end
      end
    end
  end
end
