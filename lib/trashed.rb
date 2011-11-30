begin
  require 'active_support/all'
rescue LoadError
  require 'active_support'
end

module Trashed
  require 'trashed/metrics'
end
