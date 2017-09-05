require 'trashed/test_helper'

class MeterTest < Minitest::Test
  def test_counts
    meter = Trashed::Meter.new
    i = 0
    meter.counts(:foo) { i += 1 }

    counters = {}
    assert_equal :result, meter.instrument!({}, counters, []) { :result }
    assert_equal 1, counters[:foo]
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
    def i.start(state, counters, gauges) state[:foo] = 10 end
    def i.measure(state, counters, gauges)
      counters[:foo] = state.delete(:foo) - 2
      gauges << [ :bar, 2 ]
    end
    meter = Trashed::Meter.new
    meter.instrument i

    counters, gauges = {}, []
    assert_equal :result, meter.instrument!({}, counters, gauges) { :result }
    assert_equal 8, counters[:foo]
    assert_equal [[ :bar, 2 ]], gauges
  end
end
