require 'trashed'
require 'rails/railtie'
require 'active_support/ordered_options'

module Trashed
  class Railtie < ::Rails::Railtie
    config.trashed = ActiveSupport::OrderedOptions.new
    config.trashed.statsd = ActiveSupport::OrderedOptions.new

    initializer 'trashed' do |app|
      app.config.trashed.sample_rate ||= 0.1
      app.config.trashed.statsd = connect_to_statsd(app.config.trashed[:statsd])
      app.config.trashed.logger = Rails.logger
    end

    initializer 'trashed.middleware', :after => 'trashed', :before => 'trashed.newrelic' do |app|
      app.middleware.insert_after '::Rack::Lock', Trashed::Rack::MeasureResourceUsage, app.config.trashed
    end

    initializer 'trashed.newrelic', :after => 'newrelic_rpm.start_plugin' do |app|
      if NewRelic::Control.instance.agent_enabled?
        require 'trashed/new_relic'
        Trashed::NewRelic.sample ResourceUsage, app.config.trashed
      end
    end

    def connect_to_statsd(options)
      require 'statsd'

      case options
      when Statsd
        options
      when Hash
        Statsd.new(options[:host], options[:port]).tap do |statsd|
          statsd.namespace = options[:namespace]
        end
      end
    end
  end
end
