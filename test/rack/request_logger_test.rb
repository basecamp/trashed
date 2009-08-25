require 'test_helper'
require 'trashed/rack/request_logger'

class RackRequestLoggerTest < ActiveSupport::TestCase
  Hello = [200, {}, ['hello']]
  HelloApp = lambda { |env| Hello }

  def setup
    super
    @logger = []
    def @logger.info(message) self << message end
  end

  test 'raises if given non-metrics' do
    assert_raise RuntimeError do
      Trashed::Rack::RequestLogger.new(HelloApp, @logger, Object.new)
    end
  end

  test 'raises if metric is unavailable' do
    assert_raise RuntimeError do
      Trashed::Rack::RequestLogger.new(HelloApp, @logger, [Trashed::Metrics::Metric.new(:a, :b, lambda { false }, lambda { 1 })])
    end
  end

  test 'logs measurements after calling app' do
    metric = Trashed::Metrics::Metric.new('label', :units, lambda { true }, lambda { 2 })
    logger_app = Trashed::Rack::RequestLogger.new(HelloApp, @logger, [metric, metric])

    assert_equal [], @logger
    assert_equal Hello, logger_app.call({})
    assert_equal ['[Trashed] label: 2 units; label: 2 units'], @logger
  end
end
