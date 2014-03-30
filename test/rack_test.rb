require 'trashed/test_helper'

class RackTest < Minitest::Test
  Hello = lambda { |env| [200, {}, %w(hello)] }

  def setup
    @reporter = Object.new
    def @reporter.report(env) end
    def @reporter.sample?(env) true end
  end

  def test_instruments_app_and_stores_in_env
    env = {}
    response = Trashed::Rack.new(Hello, @reporter).call(env)
    refute_nil env[Trashed::Rack::TIMINGS]
    refute_nil env[Trashed::Rack::TIMINGS][:'Time.wall']
    refute_nil env[Trashed::Rack::GAUGES]
  end
end
