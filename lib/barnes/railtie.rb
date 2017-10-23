require 'rails/railtie'
require 'barnes/reporter'
require 'barnes/resource_usage'

module Barnes
  # Automatically configures barnes to run with
  # rails 3, 4, and 5. Configuration can be changed
  # in the application.rb. For example
  #
  #   module YourApp
  #     class Application < Rails::Application
  #     config.barnes[:interval] = 20
  #
  class Railtie < ::Rails::Railtie
    config.barnes = {
      interval:           DEFAULT_INTERVAL,
      aggregation_period: DEFAULT_AGGREGATION_PERIOD,
      statsd:             DEFAULT_STATSD,
      panels:             DEFAULT_PANELS,
    }

    initializer 'barnes' do |app|
      Barnes.start(config.barnes)
    end
  end
end
