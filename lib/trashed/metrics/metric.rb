module Trashed
  module Metrics
    # Convenience class for simple metrics. Instantiate with a label, units,
    # and lambdas for availability checking and measurement.
    class Metric
      attr_reader :label, :units

      def initialize(label, units, availability_check, measurer)
        @label, @units = label.to_s, units.to_sym
        @availability_check, @measurer = availability_check, measurer
      end

      def available?
        !!@availability_check.call
      end

      def measure
        @measurer.call
      end
    end
  end
end
