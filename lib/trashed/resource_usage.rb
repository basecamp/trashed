module Trashed
  ResourceUsage = Meter.new do

    # Wall clock time, in milliseconds
    counts :Time do
      { :wall => (Time.now.to_f * 1000).to_i }
    end

    # RailsBench GC patch / REE 1.8
    if GC.respond_to? :enable_stats
      GC.enable_stats

      counts :Objects do
        { :total => ObjectSpace.allocated_objects }
      end

      gauges :Objects do
        { :live => ObjectSpace.live_objects }
      end

      counts :GC do
        { :count => GC.collections, :elapsed => GC.time, :memory => GC.allocated_size }
      end

      gauges :GC do
        { :growth => GC.growth }
      end

    # Ruby 1.9+
    elsif ObjectSpace.respond_to? :count_objects
      gauges :Objects do
        ObjectSpace.count_objects
      end

      counts :GC do
        { :count => GC.stat[:count] }
      end

      gauges :GC do
        GC.stat
      end
    end
  end
end
