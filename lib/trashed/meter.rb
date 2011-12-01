module Trashed
  class Meter
    attr_reader :counters, :gauges

    def initialize(&block)
      @counters, @gauges = {}, {}
      instance_eval(&block) if block_given?
    end

    def counts(name, &block) @counters[name] = block end
    def count; read @counters end

    def gauges(name, &block) @gauges[name] = block end
    def gauge; read @gauges end

    def instrument
      before = count
      yield
      delta before, count
    end

    private

    def delta(before, after)
      delta = {}
      after.each { |k, v| delta[k] = v - before[k] }
      delta
    end

    def read(measures)
      data = {}
      measures.each do |name, measure|
        measure.call.each do |key, value|
          data["#{name}.#{key}"] = value
        end
      end
      data
    end
  end
end
