module Trashed
  module Metrics
    module Lookup #:nodoc:
      # Metrics['Objects/Live'] # => Trashed::Metrics::Objects::Live
      def [](label)
        if label.respond_to?(:measure)
          label
        else
          lookup[label.to_s]
        end
      end

      def add(*metrics)
        metrics.each do |metric|
          lookup[metric.label.to_s] = metric
        end
        metrics
      end

      # Metrics.all # => [Trashed::Metrics::Objects::Live]
      def all
        lookup.values
      end

      # Shortcut for Metrics.all.select(&:available?)
      def available
        all.select(&:available?)
      end

      private
        def lookup
          @lookup ||= {}
        end
    end
  end
end
