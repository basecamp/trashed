require 'trashed'
require 'rails/railtie'

module Trashed
  class Railtie < ::Rails::Railtie
    config.trashed = Struct.new(:debug, :logger, :statsd).new

    initializer 'trashed.logger' do |app|
      config.trashed.logger ||= Rails.logger
    end

    initializer 'trashed.middleware' do |app|
      app.middleware.insert_after '::Rack::Lock', Trashed::Rack::MeasureResourceUsage,
        :debug => config.trashed.debug, :logger => config.trashed.logger
    end

    initializer 'trashed.newrelic', :after => 'newrelic_rpm.start_plugin' do |app|
      if NewRelic::Control.instance.agent_enabled?
        require 'trashed/new_relic'
        Trashed::NewRelic.sample ResourceUsage, :statsd => config.trashed.statsd
      end
    end
  end
end
