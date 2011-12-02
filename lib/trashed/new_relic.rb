module Trashed
  module NewRelic
    def self.sample(meter, options = {})
      ::NewRelic::Agent.instance.stats_engine.add_sampler Sampler.new(meter, options)
    end

    class Sampler
      attr_accessor :stats_engine

      def initialize(meter, options = {})
        @meter  = meter
        @label  = options[:label] || 'Custom/%s'
        @statsd = options[:statsd]
      end

      def poll
        record @meter.count
        record @meter.gauge
      end

      def record(data)
        data.each do |name, value|
          record_newrelic name, value
          record_statsd   name, value if @statsd
        end
      end

      private

      def record_statsd(name, value)
        @statsd.timing "Performance.#{name}", value
      end

      def record_newrelic(name, value)
        stats_for(label_for(name)).record_data_point(value)
      end

      def stats_for(metric)
        stats_engine.get_stats(metric, false)
      end

      def label_for(name)
        @label % name.gsub('.', '/')
      end
    end
  end
end
