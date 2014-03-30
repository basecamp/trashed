require 'trashed/test_helper'
require 'trashed/reporter'
require 'logger'
require 'stringio'

class ReporterTest < Minitest::Test
  def setup
    @reporter = Trashed::Reporter.new
  end

  def test_sample_rate_defaults_to_1
    assert_equal 1.0, @reporter.sample_rate
  end

  def test_random_sample?
    @reporter.sample_rate = 0.2

    def @reporter.rand; 0.3 end
    assert !@reporter.sample?

    def @reporter.rand; 0.2 end
    assert !@reporter.sample?

    def @reporter.rand; 0.1 end
    assert @reporter.sample?
  end

  def test_report_logger
    assert_report_logs 'Rack handled in 1.00ms.'
    assert_report_logs 'Rack handled in 1.00ms (10.0% cpu, 90.0% idle).', :'Time.pct.cpu' => 10, :'Time.pct.idle' => 90

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

    assert_report_logs 'Rack handled in 1.00ms (10.0% cpu, 90.0% idle). 10 objects. 2 GCs (3 major, 4 minor) took 10.00ms. Avoided 3 OOB GCs (4 major, 5 minor, 6 sweep) saving 10.00ms.',
      :'Time.pct.cpu' => 10, :'Time.pct.idle' => 90,
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

    @reporter.report_logger 'trashed.logger.tags' => %w(a b c), 'trashed.timings' => { :'Time.wall' => 1 }
    assert_match 'Rack handled in 1.00ms.', out.string
    assert_equal %w(a b c), logger.tags
  end

  private
  def assert_report_logs(string, timings = {})
    @reporter.logger = Logger.new(out = StringIO.new)
    @reporter.report_logger 'trashed.timings' => timings.merge(:'Time.wall' => 1)
    assert_match string, out.string
  end
end
