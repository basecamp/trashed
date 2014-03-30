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
    @reporter.logger = Logger.new(out = StringIO.new)
    @reporter.report_logger 'trashed.timings' => { :'Time.wall' => 1, :'GC.count' => 2 }
    assert_match 'Rack handled in 1ms (GC runs: 2)', out.string
  end
end
