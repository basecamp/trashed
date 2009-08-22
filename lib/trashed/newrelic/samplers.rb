module Trashed
  class Sampler < NewRelic::Agent::Sampler
    def initialize
      super self.class::LABEL.sub(/Sampler$/, '').underscore.to_sym
    end

    def poll
      stats.record_data_point(sample)
    end

    protected
      def stats
        stats_engine.get_stats(self.class::LABEL, false)
      end
  end

  class PointSampler < Sampler
    def sample
      measure
    end
  end

  class DeltaSampler < Sampler
    def initialize
      super
      mark!
    end

    def sample
      old = @mark
      mark!
      @mark - old
    end

    protected
      def mark!
        @mark = measure
      end
  end

  class LiveObjectsSampler < PointSampler
    LABEL = 'Custom/Objects/Live'

    def self.available?
      ObjectSpace.respond_to?(:live_objects)
    end

    def measure
      ObjectSpace.live_objects
    end
  end

  class AllocatedObjectsSampler < DeltaSampler
    LABEL = 'Custom/Objects/Allocated'

    def self.available?
      ObjectSpace.respond_to?(:allocated_objects)
    end

    def measure
      ObjectSpace.allocated_objects
    end
  end
end
