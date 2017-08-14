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

class RackReporterTest < Minitest::Test
  def setup
    @reporter = Trashed::RackReporter.new
    @reporter.counter_sample_rate = 1
    @reporter.gauge_sample_rate = 1
  end

  def test_sample_rate_defaults
    assert_equal 0.1, Trashed::RackReporter.new.counter_sample_rate
    assert_equal 0.05, Trashed::RackReporter.new.gauge_sample_rate
  end

  def test_report_logger
    assert_report_logs 'Rack handled in 1.00ms.'
    assert_report_logs 'Rack handled in 1.00ms (9.9% cpu, 90.1% idle).', :'Time.pct.cpu' => 9.9, :'Time.pct.idle' => 90.1

    assert_report_logs 'Rack handled in 1.00ms.', :'GC.allocated_objects' => 0
    assert_report_logs 'Rack handled in 1.00ms. 10 objects.', :'GC.allocated_objects' => 10

    assert_report_logs 'Rack handled in 1.00ms. 0 GCs.', :'GC.count' => 0
    assert_report_logs 'Rack handled in 1.00ms. 2 GCs.', :'GC.count' => 2
    assert_report_logs 'Rack handled in 1.00ms. 2 GCs (3 major, 4 minor).', :'GC.count' => 2, :'GC.major_count' => 3, :'GC.minor_count' => 4
    assert_report_logs 'Rack handled in 1.00ms. 2 GCs took 10.00ms.', :'GC.count' => 2, :'GC.time' => 10

    assert_report_logs 'Rack handled in 1.00ms.', :'OOBGC.count' => 0
    assert_report_logs 'Rack handled in 1.00ms. 0 GCs. Avoided 3 OOB GCs.', :'OOBGC.count' => 3
    assert_report_logs 'Rack handled in 1.00ms. 0 GCs. Avoided 3 OOB GCs (4 major, 5 minor, 6 sweep).', :'OOBGC.count' => 3, :'OOBGC.major_count' => 4, :'OOBGC.minor_count' => 5, :'OOBGC.sweep_count' => 6
    assert_report_logs 'Rack handled in 1.00ms. 0 GCs. Avoided 3 OOB GCs saving 10.00ms.', :'OOBGC.count' => 3, :'OOBGC.time' => 10

    assert_report_logs 'Rack handled in 1.00ms (9.1% cpu, 90.1% idle). 10 objects. 2 GCs (3 major, 4 minor) took 10.00ms. Avoided 3 OOB GCs (4 major, 5 minor, 6 sweep) saving 10.00ms.',
      :'Time.pct.cpu' => 9.1, :'Time.pct.idle' => 90.1,
      :'GC.allocated_objects' => 10,
      :'GC.count' => 2, :'GC.time' => 10,
      :'GC.major_count' => 3, :'GC.minor_count' => 4,
      :'OOBGC.count' => 3, :'OOBGC.time' => 10,
      :'OOBGC.major_count' => 4, :'OOBGC.minor_count' => 5, :'OOBGC.sweep_count' => 6
  end

  def test_tagged_logger
    @reporter.logger = logger = Logger.new(out = StringIO.new)
    class << logger
      attr_reader :tags
      def tagged(tags) @tags = tags; yield end
    end

    @reporter.report_logger 'trashed.logger.tags' => %w(a b c), Trashed::COUNTERS => { :'Time.wall' => 1 }
    assert_match 'Rack handled in 1.00ms.', out.string
    assert_equal %w(a b c), logger.tags
  end

  private
  def assert_report_logs(string, counters = {})
    @reporter.logger = Logger.new(out = StringIO.new)
    @reporter.report_logger Trashed::COUNTERS => counters.merge(:'Time.wall' => 1)
    assert_match string, out.string
  end
end

class PeriodicReporterTest < Minitest::Test
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
