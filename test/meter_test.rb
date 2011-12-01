require 'trashed/test_helper'

class MeterTest < MiniTest::Unit::TestCase
  def test_count
    time = Trashed::ResourceUsage.count['Time.wall']
    refute_nil time
    assert_in_delta time, (Time.now.to_f * 1000), 1000
  end

  def test_instrument
    elapsed = Trashed::ResourceUsage.instrument { nil }['Time.wall']
    refute_nil elapsed
    assert_in_delta elapsed, 0, 1000
  end
end
