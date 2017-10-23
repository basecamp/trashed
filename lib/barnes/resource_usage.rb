require 'barnes/panel'

module Barnes
  class ResourceUsage < Panel
    def initialize(sample_rate)
      super()

      require 'barnes/instruments/stopwatch'
      instrument Barnes::Instruments::Stopwatch.new

      if GC.respond_to? :enable_stats
        require 'barnes/instruments/ree_gc'
        instrument Barnes::Instruments::Ruby18GC.new
      end

      # Ruby 1.9+
      if ObjectSpace.respond_to? :count_objects
        require 'barnes/instruments/object_space_counter'
        instrument Barnes::Instruments::ObjectSpaceCounter.new
      end

      # Ruby 1.9+
      if GC.respond_to?(:stat)
        require 'barnes/instruments/ruby_gc'
        instrument Barnes::Instruments::RubyGC.new(sample_rate)
      end

      # Ruby 2.1+ with https://github.com/tmm1/gctools
      if defined? GC::OOB
        require 'barnes/instruments/gctools_oobgc'
        instrument Barnes::Instruments::GctoolsOobgc.new
      end
    end
  end
end
