require 'trashed'
require 'rails/railtie'

module Trashed
  class Railtie < ::Rails::Railtie
    config.trashed = { :debug => false, :statsd => nil, :logger => nil }

    initializer 'measurement middleware' do |app|
      app.middleware.insert_after '::Rack::Lock', Trashed::Rack::MeasureResourceUsage, config.trashed.merge(:logger => Rails.logger)
    end

    initializer 'newrelic sampler' do |app|
      if NewRelic::Control.instance.agent_enabled?
        require 'trashed/new_relic'
        Trashed::NewRelic.sample ResourceUsage, config.trashed
      end
    end
  end
end
