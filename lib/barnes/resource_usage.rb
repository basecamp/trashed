require 'barnes/meter'

module Barnes
  ResourceUsage = Meter.new.tap do |meter|
    # Wall clock time in milliseconds since epoch.
    # Includes CPU and idle time on Ruby 2.1+.
    require 'barnes/instruments/stopwatch'
    meter.instrument Barnes::Instruments::Stopwatch.new

    # RailsBench GC patch / REE 1.8
    if GC.respond_to? :enable_stats
      require 'barnes/instruments/ree_gc'
      meter.instrument Barnes::Instruments::Ruby18GC.new
    end

    # Ruby 1.9+
    if ObjectSpace.respond_to? :count_objects
      require 'barnes/instruments/object_space_counter'
      meter.instrument Barnes::Instruments::ObjectSpaceCounter.new
    end

    # Ruby 1.9+
    if GC.respond_to?(:stat)
      require 'barnes/instruments/ruby_gc'
      meter.instrument Barnes::Instruments::RubyGC.new
    end

    # Ruby 1.9+
    if defined? GC::Profiler
      require 'barnes/instruments/ruby_gc_profiler'
      meter.instrument Barnes::Instruments::RubyGCProfiler.new
    end

    # Ruby 2.1+ with https://github.com/tmm1/gctools
    if defined? GC::OOB
      require 'barnes/instruments/gctools_oobgc'
      meter.instrument Barnes::Instruments::GctoolsOobgc.new
    end

  end
end
