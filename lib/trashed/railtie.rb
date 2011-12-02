require 'trashed'
require 'rails/railtie'

module Trashed
  class Railtie < ::Rails::Railtie
    class Config < Struct.new(:debug, :logger, :statsd, :sample_rate)
      def to_hash
        { :debug => debug, :logger => logger, :statsd => statsd, :sample_rate => sample_rate }
      end
    end

    config.trashed = Config.new

    initializer 'trashed' do |app|
      config.trashed.logger ||= Rails.logger
    end

    initializer 'trashed.middleware', :after => 'trashed', :before => 'trashed.newrelic' do |app|
      app.middleware.insert_after '::Rack::Lock', Trashed::Rack::MeasureResourceUsage, config.trashed.to_hash
    end

    initializer 'trashed.newrelic', :after => 'newrelic_rpm.start_plugin' do |app|
      if NewRelic::Control.instance.agent_enabled?
        require 'trashed/new_relic'
        Trashed::NewRelic.sample ResourceUsage, config.trashed.to_hash
      end
    end
  end
end
