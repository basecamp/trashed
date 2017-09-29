module Barnes
  class Reporter
    attr_accessor :logger, :statsd
    attr_accessor :counter_sample_rate, :gauge_sample_rate
    attr_accessor :counter_dimensions, :gauge_dimensions

    DEFAULT_DIMENSIONS = [ :All ]

    def initialize
      @logger = nil
      @statsd = nil
      @counter_sample_rate = 1.0
      @gauge_sample_rate = 1.0
      @counter_dimensions  = lambda { |env| DEFAULT_DIMENSIONS }
      @gauge_dimensions   = lambda { |env| DEFAULT_DIMENSIONS }
    end

    def report(env)
      report_statsd env if @statsd
    end

    def report_statsd(env)
      method = @statsd.respond_to?(:easy) ? :easy : :batch
      @statsd.send(method) do |statsd|
        send_to_statsd statsd, :count, @counter_sample_rate, env[Barnes::COUNTERS], :'Rack.Server', @counter_dimensions.call(env)
        send_to_statsd statsd, :gauge, @gauge_sample_rate, env[Barnes::GAUGES], :'Rack.Server', @gauge_dimensions.call(env)
      end
    end

    def send_to_statsd(statsd, method, sample_rate, measurements, namespace, dimensions)
      measurements.each do |metric, value|
        case value
        when Array
          value.each do |v|
            send_to_statsd statsd, method, sample_rate, { metric => v }, namespace, dimensions
          end
        when Numeric
          Array(dimensions || :All).each do |dimension|
            statsd.send method, :"#{namespace}.#{dimension}.#{metric}", value, sample_rate
          end
        end
      end
    end
  end
end
