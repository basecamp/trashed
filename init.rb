if GC.respond_to?(:enable_stats)
  GC.enable_stats
  require 'trashed/measurement'

  class ActionController::Dispatcher
    # Disable GC during request handling.
    #before_dispatch { GC.disable }
    #after_dispatch  { GC.enable }

    # Log resource growth per request.
    before_dispatch { Trashed::Measurement.mark! }
    after_dispatch  { Trashed::Measurement.delta.log! }
  end

  Rails.logger.info '*** Resource growth measurements enabled (running patched ruby) ***'
else
  Rails.logger.info '*** Resource growth measurements disabled (running unpatched ruby) ***'
end
