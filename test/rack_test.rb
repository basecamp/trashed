require 'trashed/test_helper'

class RackTest < MiniTest::Unit::TestCase
  Hello = lambda { |env| [200, {}, %w(hello)] }

  def test_instruments_app_and_stores_in_env
    env = {}

    response = Trashed::Rack::MeasureResourceUsage.new(Hello).call(env)

    refute_nil env['trashed.change']
    refute_nil env['trashed.usage']

    elapsed = env['trashed.change']['Time.wall']
    refute_nil elapsed
    assert_in_delta elapsed, 0, 1000
  end
end
