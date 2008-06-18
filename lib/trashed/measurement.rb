module Trashed
  class Measurement < Struct.new(:time, :memory, :objects, :gc_runs, :gc_time)
    FORMAT = 'STATS: %d ms, %.2f KB, %d obj, %d GCs in %d ms'.freeze

    class << self
      def mark!; @mark = now  end
      def delta; now - @mark  end

      def now
        new(Time.now.to_f, GC.allocated_size, ObjectSpace.allocated_objects, GC.collections, GC.time)
      end
    end

    mark!

    def -(other)
      self.class.new(time - other.time,
        memory - other.memory, objects - other.objects,
        gc_runs - other.gc_runs, gc_time - other.gc_time)
    end

    def log!
      Rails.logger.info(to_s)
    end

    def to_s
      FORMAT % [time * 1000,
        memory / 1024.0, objects,
        gc_runs, gc_time / 1000.0]
    end
  end
end
