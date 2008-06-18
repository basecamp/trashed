if GC.respond_to?(:enable_stats)
  GC.enable_stats

  # Log resource growth per request.
  require 'trashed/request_measurement'
  ActionController::Base.send :include, Trashed::RequestMeasurement

  # Enable NewRelic live objects sampler
  if defined?(::RPM_AGENT_ENABLED) && ::RPM_AGENT_ENABLED
    require 'trashed/newrelic_sampler'
  end

  Rails.logger.info '*** Resource growth measurements enabled (running patched ruby) ***'
else
  Rails.logger.info '*** Resource growth measurements disabled (running unpatched ruby) ***'
end
