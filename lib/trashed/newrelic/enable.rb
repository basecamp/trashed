require 'trashed/newrelic/samplers'

agent = NewRelic::Agent.instance
Trashed::LiveObjectsSampler.new.install!(agent)
Trashed::AllocatedObjectsSampler.new.install!(agent)
