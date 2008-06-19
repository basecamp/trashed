module Trashed
  module Benchmarker
    def mark!; @mark = now end
    def delta; now - @mark end
    def log!;  Rails.logger.info(delta.to_s) end
  end

  class AdymoMeasurement < Struct.new(:time, :memory, :objects, :gc_runs, :gc_time)
    extend Benchmarker
    FORMAT = 'STATS: %d ms, %.2f KB, %d obj, %d GCs in %d ms'.freeze

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
