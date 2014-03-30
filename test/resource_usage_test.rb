require 'trashed/test_helper'

class ResourceUsageTest < Minitest::Test
  def setup
    super
    @meter = Trashed::ResourceUsage
  end

  def test_wall_time
    assert_in_delta 0, timing(:'Time.wall'), 1000
  end

  if Process.respond_to?(:clock_gettime)
    def test_cpu_and_idle_time
      assert_in_delta 0, timing(:'Time.cpu'), 1000
      assert_in_delta 0, timing(:'Time.idle'), 1000
    end
  end

  private
  def timing(metric)
    timings = {}
    assert_equal :result, @meter.instrument!({}, timings, []) { :result }
    assert timings.include?(metric), timings.inspect
    timings[metric]
  end
end
