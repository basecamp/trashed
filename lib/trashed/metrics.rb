require 'trashed/metrics/lookup'
require 'trashed/metrics/metric'
require 'trashed/metrics/change'
require 'trashed/metrics/compound'

module Trashed
  # A metric is what we use to measure. Duck type:
  #   label       => string
  #   units       => symbol
  #   available?  => boolean
  #   measure     => any object
  module Metrics
    extend Lookup

    module Objects
      Live = Metric.new('Objects/Live', :Kobj,
        lambda { ObjectSpace.respond_to?(:live_objects) },
        lambda { ObjectSpace.live_objects / 1000.0 })

      AllocatedTotal = Metric.new('Objects/Allocated/Total', :Kobj,
        lambda { ObjectSpace.respond_to?(:allocated_objects) },
        lambda { ObjectSpace.allocated_objects / 1000.0 })
      Allocated = Change.new('Objects/Allocated', AllocatedTotal)
    end

    module GC
      RunsTotal = Metric.new('GC/Runs/Total', :times,
        lambda { ::GC.respond_to?(:runs) },
        lambda { ::GC.runs })
      Runs = Change.new('GC/Runs', RunsTotal)

      TimeTotal = Metric.new('GC/Time/Total', :sec,
        lambda { ::GC.respond_to?(:time) },
        lambda { ::GC.time / 1000.0 })
      Time = Change.new('GC/Time', TimeTotal)

      MallocTotal = Metric.new('GC/Malloc/Total', :bytes,
        lambda { ::GC.respond_to?(:allocated_size) },
        lambda { ::GC.allocated_size / 1024.0 })
      Malloc = Change.new('GC/Malloc', MallocTotal)
    end

    add Objects::Live,
      Objects::AllocatedTotal, Objects::Allocated,
      GC::RunsTotal, GC::Runs,
      GC::TimeTotal, GC::Time,
      GC::MallocTotal, GC::Malloc
  end
end
