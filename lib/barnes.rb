module Barnes
  DEFAULT_INTERVAL           = 10
  DEFAULT_AGGREGATION_PERIOD = 60
  DEFAULT_STATSD             = :default
  DEFAULT_PANELS             = []


  # Starts the reporting client
  #
  # Arguments:
  #
  #   - interval: How often, in seconds, to instrument and report
  #   - aggregation_period: The minimal aggregation period in use, in seconds.
  #   - statsd: The statsd reporter. This should be an instance of statsd-ruby
  #   - panels: The instrumentation "panels" in use. See `resource_usage.rb` for
  #     an example panel, which is the default if none are provided.
  def self.start(interval: DEFAULT_INTERVAL, aggregation_period: DEFAULT_AGGREGATION_PERIOD, statsd: DEFAULT_STATSD, panels: DEFAULT_PANELS)
    require 'statsd'
    statsd_client = statsd
    panels        = panels
    sample_rate   = interval.to_f / aggregation_period.to_f

    if statsd_client == :default
      statsd_client = Statsd.new('127.0.0.1', ENV["PORT"]) if ENV["PORT"]
    end

    if statsd_client
      reporter = Barnes::Reporter.new(statsd: statsd_client, sample_rate: sample_rate)

      unless panels.length > 0
        panels << Barnes::ResourceUsage.new(sample_rate)
      end

      Periodic.new reporter: reporter, sample_rate: sample_rate, panels: panels
    end
  end
end

require 'barnes/periodic'
require 'barnes/railtie' if defined? ::Rails::Railtie
