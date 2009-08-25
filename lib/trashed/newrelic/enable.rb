require 'trashed'
require 'trashed/newrelic'

module Trashed::NewRelic
  sample 'Objects/Live'
  sample 'Objects/Allocated'

  sample 'GC/Runs'
  sample 'GC/Time'
  sample 'GC/Malloc'
end
