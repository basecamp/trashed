require 'test_helper'

class SimpleMetricTest < ActiveSupport::TestCase
  def setup
    super
    @metric = Trashed::Metrics::Metric.new(:label, 'units', lambda { 1 }, lambda { 1 })
  end

  test 'responds to label and units with string and symbol' do
    assert_equal 'label', @metric.label
    assert_equal :units, @metric.units
  end

  test 'responds to available? with boolean' do
    assert_equal true, @metric.available?
  end

  test 'responds to measure with any object' do
    assert_equal 1, @metric.measure
  end
end

class ChangeMetricTest < ActiveSupport::TestCase
  def setup
    super
    @metric = Trashed::Metrics::Metric.new(:label, 'units', lambda { 1 }, lambda { 1 })
    @change = Trashed::Metrics::Change.new(:change, @metric)
  end

  test 'uses its own label' do
    assert_equal 'change', @change.label
  end

  test 'delegates units and availability to metric' do
    assert_equal @change.metric.units, @change.units
    assert_equal @change.metric.available?, @change.available?
  end

  test 'measures difference from last metric measurement' do
    assert_equal 0, @change.measure
    assert_equal 0, @change.measure
  end

  test 'measures 0 if metric is unavailable' do
    metric = Trashed::Metrics::Metric.new(:a, :b, lambda { false }, lambda { 1 })
    change = Trashed::Metrics::Change.new(:change, metric)
    assert_equal 0, change.measure
    assert_equal 0, change.measure
  end

  test 'raises if measurement does not respond to -' do
    metric = Trashed::Metrics::Metric.new(:a, :b, lambda { true }, lambda { Object.new })
    assert_raise RuntimeError do
      Trashed::Metrics::Change.new(:change, metric)
    end
  end
end

class CompoundMetricTest < ActiveSupport::TestCase
  def setup
    super
    @one = Trashed::Metrics::Metric.new('one', :a, lambda { true }, lambda { 1 })
    @two = Trashed::Metrics::Metric.new('two', :b, lambda { true }, lambda { 2 })
    @both = Trashed::Metrics::Compound.new(:compound, [@one, @two])

    @dead = Trashed::Metrics::Metric.new('dead', :a, lambda { false }, lambda { 3 })
  end

  test 'expects an array of metrics' do
    assert_raise RuntimeError do
      Trashed::Metrics::Compound.new(:compound, @one)
    end
  end

  test 'has its own label' do
    assert_equal 'compound', @both.label
  end

  test 'units is array of child units' do
    assert_equal [@one.units, @two.units], @both.units
  end

  test 'available if all metrics available' do
    compound = Trashed::Metrics::Compound.new(:a, [@one, @dead])
    assert_equal false, compound.available?
  end

  test 'measurement is hash of child measurements' do
    measurement = @both.measure
    assert_equal 1, measurement[@one.label]
    assert_equal 2, measurement[@two.label]
  end

  test 'measurement is subtractable' do
    first = @both.measure
    second = @both.measure
    delta = second - first

    assert_equal 0, delta[@one.label]
    assert_equal 0, delta[@two.label]
  end
end

class LookupTest < ActiveSupport::TestCase
  def setup
    super
    @metrics = Object.new
    @metrics.extend Trashed::Metrics::Lookup

    @metric = Struct.new(:label, :measure).new('foo', 1)
    def @metric.available?; false end
    @metrics.add @metric
  end

  test 'default metrics are registered' do
    %w(Objects/Live Objects/Allocated GC/Collections GC/Time GC/Malloc).each do |label|
      metric = Trashed::Metrics[label]
      assert_not_nil metric, "Missing metric #{label}"
      assert metric.respond_to?(:measure)
      assert_equal metric, Trashed::Metrics[metric]
    end
  end

  test 'lookup returns argument if it responds to :measure' do
    assert_equal @metric, @metrics[@metric]
  end

  test 'lookup coerces label to string' do
    assert_equal @metric, @metrics[@metric.label]
    assert_equal @metric, @metrics[@metric.label.to_sym]
  end

  test 'add coerces label to string' do
    foo = Struct.new(:label).new(:foo)
    assert_equal [foo], @metrics.add(foo)
    assert_equal foo, @metrics[foo.label.to_s]
  end

  test 'all returns a list of added metrics' do
    assert_equal [@metric], @metrics.all
  end

  test 'available returns a list of added metrics whose measurements are available' do
    assert_equal [], @metrics.available
  end
end
