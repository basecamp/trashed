require 'trashed/rack'

require "trashed/reporter/aggregator"

module Trashed
  module Reporter
    autoload :Logger, "trashed/reporter/logger"
    autoload :Statsd, "trashed/reporter/statsd"
  end
end
