require 'trashed'
require 'minitest/autorun'

class Statsd
  def initialize(batcher)
    @batcher = batcher
  end
  def batch
    yield @batcher
  end
end
