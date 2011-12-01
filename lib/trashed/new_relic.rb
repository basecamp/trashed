module Trashed
  module NewRelic
    def self.sample(meter, options = nil)
      ::NewRelic::Agent.instance.stats_engine.add_sampler Sampler.new(meter, options)
    end

    class Sampler
      attr_accessor :stats_engine

      def initialize(meter, options = nil)
        @meter = meter
        @label, @statsd = options.values_at(:label, :statsd) if options
        @label ||= 'Custom/%s'
      end

      def poll
        @meter.gauge.each do |name, value|
          record_statsd   name, value
          record_newrelic name, value
        end
      end

      private

      def record_statsd(name, value)
        @statsd.timing "Performance.#{name}", value if @statsd
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
