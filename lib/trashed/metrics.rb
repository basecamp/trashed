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
      Live = Metric.new('Objects/Live', :objects,
        lambda { ObjectSpace.respond_to?(:live_objects) },
        lambda { ObjectSpace.live_objects })

      AllocatedTotal = Metric.new('Objects/Allocated/Total', :objects,
        lambda { ObjectSpace.respond_to?(:allocated_objects) },
        lambda { ObjectSpace.allocated_objects })
      Allocated = Change.new('Objects/Allocated', AllocatedTotal)
    end

    module GC
      RunsTotal = Metric.new('GC/Runs/Total', :times,
        lambda { ::GC.respond_to?(:runs) },
        lambda { ::GC.runs })
      Runs = Change.new('GC/Runs', RunsTotal)

      TimeTotal = Metric.new('GC/Time/Total', :ms,
        lambda { ::GC.respond_to?(:time) },
        lambda { (1000 * ::GC.time).ceil })
      Time = Change.new('GC/Time', TimeTotal)

      MallocTotal = Metric.new('GC/Malloc/Total', :bytes,
        lambda { ::GC.respond_to?(:allocated_size) },
        lambda { ::GC.allocated_size })
      Malloc = Change.new('GC/Malloc', MallocTotal)
    end

    add Objects::Live,
      Objects::AllocatedTotal, Objects::Allocated,
      GC::RunsTotal, GC::Runs,
      GC::TimeTotal, GC::Time,
      GC::MallocTotal, GC::Malloc
  end
end
