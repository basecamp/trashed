require 'trashed/test_helper'
require 'trashed/reporter'
require 'logger'
require 'stringio'

class ReporterTest < Minitest::Test
  def setup
    @reporter = Trashed::Reporter.new
  end

  def test_report_raises
    assert_raises do
      @reporter.report_logger
    end

    assert_raises do
      @reporter.report_statsd
    end
  end
end

class PeriodicReporterTest < Minitest::Test
  class Statsd
    def initialize(batcher)
      @batcher = batcher
    end
    def batch
      yield @batcher
    end
  end

  def setup
    @reporter = Trashed::PeriodicReporter.new
  end

  def test_sample_rate_defaults
    assert_equal 1, Trashed::PeriodicReporter.new.counter_sample_rate
    assert_equal 1, Trashed::PeriodicReporter.new.gauge_sample_rate
  end

  def test_report_statsd
    batch = MiniTest::Mock.new

    batch.expect :count, true, [:'Rack.Server.All.GC.allocated_objects', 10, 1.0]
    batch.expect :gauge, true, [:'Rack.Server.All.Time.pct.cpu', 9.1, 1.0]

    statsd = Statsd.new batch

    @reporter.statsd = statsd
    @reporter.report_statsd \
                Trashed::COUNTERS => { :'GC.allocated_objects' => 10 }, \
                Trashed::GAUGES => { :'Time.pct.cpu' => 9.1 }

    batch.verify
  end
end
