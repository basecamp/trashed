require 'trashed/test_helper'

class RackTest < Minitest::Test
  Hello = lambda { |env| [200, {}, %w(hello)] }

  def setup
    @reporter = Object.new
    def @reporter.report(env) end
    def @reporter.request_reporting_rate; 1 end
    def @reporter.gauge_sample_rate; 1 end
  end

  def test_instruments_app_and_stores_in_env
    env = {}
    response = Trashed::Rack.new(Hello, @reporter).call(env)
    refute_nil env[Trashed::STATE]
    refute_nil env[Trashed::STATE][:persistent]
    refute_nil env[Trashed::COUNTERS]
    refute_nil env[Trashed::COUNTERS][:'Time.wall']
    refute_nil env[Trashed::GAUGES]
  end

  def test_persistent_thread_state
    app = lambda { |env| env[Trashed::STATE][:persistent][:foo] = env[Trashed::STATE][:persistent][:foo].to_i + 1 }
    rack = Trashed::Rack.new(app, @reporter)

    env = {}
    rack.call env
    assert_equal 1, env[Trashed::STATE][:persistent][:foo]

    rack.call env
    assert_equal 2, env[Trashed::STATE][:persistent][:foo]
  end
end
