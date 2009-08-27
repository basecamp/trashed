require 'trashed'

module Trashed
  module NewRelic
    class << self
      def sample(metric)  add_sampler metric, :add_sampler end
      def harvest(metric) add_sampler metric, :add_harvest_sampler end

      private
        def add_sampler(metric, add_method)
          if sampler = Sampler.build(metric)
            ::NewRelic::Agent.instance.stats_engine.send(add_method, sampler)
            ::NewRelic::Control.instance.log "[Trashed] sampling #{metric}"
          end
        end
    end

    class Sampler
      def self.build(label_or_metric)
        if metric = Trashed::Metrics[label_or_metric] and metric.available?
          new(metric)
        end
      end

      attr_accessor :stats_engine

      def initialize(metric)
        @metric, @label = metric, "Custom/#{metric.label}"
      end

      def poll
        stats.record_data_point(@metric.measure)
      end

      protected
        def stats
          stats_engine.get_stats(@label, false)
        end
    end
  end
end
