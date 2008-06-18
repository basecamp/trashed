module Trashed
  module RequestMeasurement
    LOG_MESSAGE = 'STATS: %s | %s [%s]'.freeze

    def self.included(base)
      base.send :around_filter, :measure_resource_usage
    end

    protected
      def measure_resource_usage
        before = Measurement.now
        yield
      ensure
        change = Measurement.now - before
        Rails.logger.info(LOG_MESSAGE % [change.to_s,
          headers['Status'].to_s, (complete_request_uri rescue 'unknown')])
      end

    class Measurement < Struct.new(:time, :memory, :objects, :gc_runs, :gc_time)
      PP_FORMAT = '%d ms, %.2f KB, %d obj, %d GCs in %d ms'.freeze

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
