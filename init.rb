require 'action_controller/dispatcher'
require 'trashed/measurement'

has_adymo = GC.respond_to?(:enable_stats)
has_lloyd = GC.respond_to?(:heap_info)

if has_adymo || has_lloyd
  if has_adymo
    GC.enable_stats
    Trashed::Measurement = Trashed::AdymoMeasurement
    Rails.logger.info 'STATS: time, memory, objects, GC runs, GC time (adymo patch)'
  else
    Trashed::Measurement = Trashed::LloydMeasurement
    Rails.logger.info 'STATS: time, heap size, max heap size, GC runs (lloyd patch)'
  end

  class ActionController::Dispatcher
    before_dispatch { Trashed::Measurement.mark! }
    after_dispatch  { Trashed::Measurement.log! }
  end
else
  Rails.logger.info '*** Resource growth measurements disabled (running unpatched ruby) ***'
end
