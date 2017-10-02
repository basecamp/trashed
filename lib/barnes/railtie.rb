require 'rails/railtie'
require 'barnes/reporter'
require 'barnes/resource_usage'

module Barnes
  class Railtie < ::Rails::Railtie
    config.barnes = {
      # How often, in seconds, to instrument and report
      :interval => 10,

      # The minimal aggregation period in use, in seconds.
      :aggregation_period => 60,

      # The statsd reporter. This should be an instance of statsd-ruby
      :statsd => nil,

      # The instrumentation "panels" in use. See `resource_usage.rb` for
      # an example panel, which is the default if none are provided.
      :panels => [],
    }

    initializer 'barnes' do |app|
      require 'statsd'

      sample_rate = config.barnes[:interval] / config.barnes[:aggregation_period]
      panels = config.barnes[:panels]

      if config.barnes[:statsd]
        reporter = Barnes::Reporter.new(config.barnes[:statsd], sample_rate)

        unless config.barnes[:panels].length > 0
          panels << Barnes::ResourceUsage.new(sample_rate)
        end

        Periodic.new reporter, sample_rate, panels
      end
    end
  end
end
