module Barnes
  # The reporter is used to send stats to the server.
  #
  # Example:
  #
  #   statsd   = Statsd.new('127.0.0.1', "8125")
  #   reporter = Reporter.new(statsd: , sample_rate: 10)
  #   reporter.report_statsd('barnes.counters' => {"hello" => 2})
  class Reporter
    attr_accessor :statsd, :sample_rate

    def initialize(statsd: , sample_rate:)
      @statsd      = statsd
      @sample_rate = sample_rate.to_f

      if @statsd.respond_to?(:easy)
        @statsd_method = statsd.method(:easy)
      else
        @statsd_method = statsd.method(:batch)
      end
    end

    def report(env)
      report_statsd env if @statsd
    end

    def report_statsd(env)
      @statsd_method.call do |statsd|
        env[Barnes::COUNTERS].each do |metric, value|
          statsd.count(:"Rack.Server.All.#{metric}", value, @sample_rate)
        end

        # for :gauge, use sample rate of 1, since gauges in statsd have no sampling characteristics.
        env[Barnes::GAUGES].each do |metric, value|
          statsd.gauge(:"Rack.Server.All.#{metric}", value, 1.0)
        end
      end
    end
  end
end
