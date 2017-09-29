require 'barnes/test_helper'
require 'barnes/reporter'
require 'logger'
require 'stringio'

class ReporterTest < Minitest::Test
  class Statsd
    def initialize(batcher)
      @batcher = batcher
    end
    def batch
      yield @batcher
    end
  end

  def setup
    @reporter = Barnes::Reporter.new
  end

  def test_sample_rate_defaults
    assert_equal 1, Barnes::Reporter.new.counter_sample_rate
    assert_equal 1, Barnes::Reporter.new.gauge_sample_rate
  end

  def test_report_statsd
    batch = MiniTest::Mock.new

    batch.expect :count, true, [:'Rack.Server.All.GC.allocated_objects', 10, 1.0]
    batch.expect :gauge, true, [:'Rack.Server.All.Time.pct.cpu', 9.1, 1.0]

    statsd = Statsd.new batch

    @reporter.statsd = statsd
    @reporter.report_statsd \
                Barnes::COUNTERS => { :'GC.allocated_objects' => 10 }, \
                Barnes::GAUGES => { :'Time.pct.cpu' => 9.1 }

    batch.verify
  end
end
