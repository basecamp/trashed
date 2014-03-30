require 'trashed/meter'

module Trashed
  ResourceUsage = Meter.new.tap do |meter|
    # Wall clock time in milliseconds since epoch.
    # Includes CPU and idle time on Ruby 2.1+.
    require 'trashed/instruments/stopwatch'
    meter.instrument Trashed::Instruments::Stopwatch.new

    # RailsBench GC patch / REE 1.8
    if GC.respond_to? :enable_stats
      require 'trashed/instruments/ree_gc'
      meter.instrument Trashed::Instruments::Ruby18GC.new
    end

    # Ruby 1.9+
    if ObjectSpace.respond_to? :count_objects
      require 'trashed/instruments/object_space_counter'
      meter.instrument Trashed::Instruments::ObjectSpaceCounter.new
    end

    # Ruby 1.9+
    if GC.respond_to?(:stat)
      require 'trashed/instruments/ruby_gc'
      meter.instrument Trashed::Instruments::RubyGC.new
    end

    # Ruby 1.9+
    if defined? GC::Profiler
      require 'trashed/instruments/ruby_gc_profiler'
      meter.instrument Trashed::Instruments::RubyGCProfiler.new
    end

    # Ruby 2.1+ with https://github.com/tmm1/gctools
    if defined? GC::OOB
      require 'trashed/instruments/gctools_oobgc'
      meter.instrument Trashed::Instruments::GctoolsOobgc.new
    end
  end
end
