require 'barnes/test_helper'
require 'barnes/resource_usage'

class ResourceUsageTest < Minitest::Test
  def setup
    super
    @state = {}
    @panel = Barnes::ResourceUsage.new(1)
    @panel.start! @state
  end

  def test_wall_time
    assert_in_delta 0, counter(:'Time.wall'), 1000
  end

  if Process.respond_to?(:clock_gettime)
    def test_cpu_and_idle_time
      assert_in_delta 0, counter(:'Time.cpu'), 1000
      assert_in_delta 0, counter(:'Time.idle'), 1000
      assert counter(:'Time.pct.cpu')
      assert counter(:'Time.pct.idle')
    end
  end

  private def counter(metric)
    counters = {}
    @panel.instrument!(@state, counters, {})
    assert counters.include?(metric), counters.inspect
    counters[metric]
  end
end
