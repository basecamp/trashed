require 'trashed/newrelic/samplers'

if agent = NewRelic::Agent.instance && agent.respond_to?(:add_sampler)
  [Trashed::LiveObjectsSampler, Trashed::AllocatedObjectsSampler].each do |sampler|
    agent.add_sampler(sampler.new) if sampler.available?
  end
end
