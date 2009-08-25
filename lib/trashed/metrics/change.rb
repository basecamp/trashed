module Trashed
  module Metrics
    class Change
      attr_reader :label, :metric
      delegate :units, :available?, :to => :metric

      def initialize(label, metric)
        @label, @metric = label.to_s, metric
        first_mark
      end

      def measure
        last, @mark = @mark, metric.measure
        @mark - last
      end

      protected
        # Disable measurement if metric is unavailable.
        # Check that the metric's measurements are subtractable.
        def first_mark
          if available?
            @mark = metric.measure
            unless @mark.respond_to?(:-)
              raise "Can't measure #{label}: #{metric.label} measurement doesn't respond to the '-' method: #{@mark.inspect}"
            end
          else
            def self.measure() 0 end
          end
        end
    end
  end
end
