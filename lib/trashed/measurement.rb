module Trashed
  class << self
    def available?
      AdymoMeasurement.available? || LloydMeasurement.available?
    end

    def enable
      klass = AdymoMeasurement.available? ? AdymoMeasurement : LloydMeasurement
      const_set :Measurement, klass
      klass.enable
      klass.mark!
    end
  end

  module Benchmarker
    def mark!; @mark = now end
    def delta; now - @mark end
    def log!;  Rails.logger.info(delta.to_s) end
  end

  class AdymoMeasurement < Struct.new(:time, :memory, :objects, :gc_runs, :gc_time)
    extend Benchmarker
    FORMAT = 'STATS: %d ms, %.2f KB, %d obj, %d GCs in %d ms'.freeze

    def self.available?
      ObjectSpace.respond_to?(:allocated_objects) &&
        %w(enable_stats allocated_size allocated_objects collections time).
        all? { |m| GC.respond_to?(m) }
    end

    def self.enable
      GC.enable_stats
      Rails.logger.info 'STATS: time, memory, objects, GC runs, GC time (adymo patch)'
    end

    def self.now
      new(Time.now.to_f, GC.allocated_size, ObjectSpace.allocated_objects, GC.collections, GC.time)
    end

    def -(other)
      self.class.new(time - other.time,
        memory - other.memory, objects - other.objects,
        gc_runs - other.gc_runs, gc_time - other.gc_time)
    end

    def to_s
      FORMAT % [time * 1000,
        memory / 1024.0, objects,
        gc_runs, gc_time / 1000.0]
    end
  end

  class LloydMeasurement < Struct.new(:time, :memory, :max_memory, :gc_runs)
    extend Benchmarker
    FORMAT = 'STATS: %d ms, %.2f KB, %.2f KB max, %d GCs'.freeze

    def self.available?
      GC.respond_to?(:heap_info)
    end

    def self.enable
      Rails.logger.info 'STATS: time, heap size, max heap size, GC runs (lloyd patch)'
    end

    def self.now
      info = GC.heap_info
      new(Time.now.to_f, info['heap_current_memory'], info['heap_max_memory'], info['num_gc_passes'])
    end

    def -(other)
      self.class.new(time - other.time, memory, max_memory, gc_runs - other.gc_runs)
    end

    def to_s
      FORMAT % [time * 1000, memory / 1024.0, max_memory / 1024.0, gc_runs]
    end
  end
end
