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
    refute_nil env[Trashed::Rack::STATE]
    refute_nil env[Trashed::Rack::STATE][:persistent]
    refute_nil env[Trashed::Rack::TIMINGS]
    refute_nil env[Trashed::Rack::TIMINGS][:'Time.wall']
    refute_nil env[Trashed::Rack::GAUGES]
  end

  def test_persistent_thread_state
    app = ->(env) { env[Trashed::Rack::STATE][:persistent][:foo] = env[Trashed::Rack::STATE][:persistent][:foo].to_i + 1 }
    rack = Trashed::Rack.new(app, @reporter)

    env = {}
    rack.call env
    assert_equal 1, env[Trashed::Rack::STATE][:persistent][:foo]

    rack.call env
    assert_equal 2, env[Trashed::Rack::STATE][:persistent][:foo]
  end
end
