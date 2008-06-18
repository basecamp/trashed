if GC.respond_to?(:enable_stats)
  GC.enable_stats

  # Log resource growth per request.
  # Disable GC during request handling.
  require 'trashed/request_measurement'
  require 'trashed/without_gc'
  class ActionController::Dispatcher
    include Trashed::RequestMeasurement
    include Trashed::WithoutGc
  end

  # Enable NewRelic live objects sampler
  #require 'trashed/newrelic_sampler' if defined?(::RPM_AGENT_ENABLED) && ::RPM_AGENT_ENABLED

  Rails.logger.info '*** Resource growth measurements enabled (running patched ruby) ***'
else
  Rails.logger.info '*** Resource growth measurements disabled (running unpatched ruby) ***'
end
