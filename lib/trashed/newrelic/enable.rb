require 'trashed/newrelic/samplers'

[Trashed::LiveObjectsSampler, Trashed::AllocatedObjectsSampler].each do |sampler|
  NewRelic::Agent.instance.add_sampler(sampler.new) if sampler.available?
end
