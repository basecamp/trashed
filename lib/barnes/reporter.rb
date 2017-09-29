module Barnes
  class Reporter
    attr_accessor :statsd, :sample_rate

    def initialize(statsd, sample_rate)
      @statsd = statsd
      @sample_rate = sample_rate
    end

    def report(env)
      report_statsd env if @statsd
    end

    def report_statsd(env)
      method = @statsd.respond_to?(:easy) ? :easy : :batch
      @statsd.send(method) do |statsd|
        send_to_statsd statsd, :count, @sample_rate, env[Barnes::COUNTERS], :'Rack.Server.All'
        send_to_statsd statsd, :gauge, 1.0, env[Barnes::GAUGES], :'Rack.Server.All'
      end
    end

    def send_to_statsd(statsd, method, sample_rate, measurements, namespace)
      measurements.each do |metric, value|
        statsd.send method, :"#{namespace}.#{metric}", value, sample_rate
      end
    end
  end
end
