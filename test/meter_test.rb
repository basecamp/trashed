require 'trashed/test_helper'

class MeterTest < Minitest::Test
  def test_counts
    meter = Trashed::Meter.new
    i = 0
    meter.counts(:foo) { i += 1 }

    timings = {}
    assert_equal :result, meter.instrument!({}, timings, []) { :result }
    assert_equal 1, timings[:foo]
  end

  def test_gauges
    meter = Trashed::Meter.new
    meter.gauges(:foo) { 1 }

    gauges = []
    assert_equal :result, meter.instrument!({}, [], gauges) { :result }
    assert_equal [[ :foo, 1 ]], gauges
  end

  def test_instruments
    i = Object.new
    def i.start(state, timings, gauges) state[:foo] = 10 end
    def i.measure(state, timings, gauges)
      timings[:foo] = state.delete(:foo) - 2
      gauges << [ :bar, 2 ]
    end
    meter = Trashed::Meter.new
    meter.instrument i

    timings, gauges = {}, []
    assert_equal :result, meter.instrument!({}, timings, gauges) { :result }
    assert_equal 8, timings[:foo]
    assert_equal [[ :bar, 2 ]], gauges
  end
end
