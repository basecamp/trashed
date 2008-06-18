module Trashed
  module RequestMeasurement
    protected
      def handle_request
        before = Measurement.now
        super
      ensure
        change = Measurement.now - before
        Rails.logger.info change.to_s
      end

    class Measurement < Struct.new(:time, :memory, :objects, :gc_runs, :gc_time)
      PP_FORMAT = 'STATS: %d ms, %.2f KB, %d obj, %d GCs in %d ms'.freeze

      def self.now
        new(Time.now.to_f,
          GC.allocated_size, ObjectSpace.allocated_objects,
          GC.collections, GC.time)
      end

      def -(other)
        self.class.new(time - other.time,
          memory - other.memory, objects - other.objects,
          gc_runs - other.gc_runs, gc_time - other.gc_time)
      end

      def to_s
        PP_FORMAT % [time * 1000,
          memory / 1024.0, objects,
          gc_runs, gc_time / 1000.0]
      end
    end
  end
end
