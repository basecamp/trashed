require 'trashed'
require 'rails/railtie'
require 'active_support/ordered_options'

module Trashed
  class Railtie < ::Rails::Railtie
    config.trashed = ActiveSupport::OrderedOptions.new
    config.trashed.statsd = ActiveSupport::OrderedOptions.new

    initializer 'trashed' do |app|
      # Debug data sent to statsd. Class-level config only :/
      Statsd.logger = app.config.trashed.logger if app.config.trashed.debug

      app.config.trashed.sample_rate ||= 0.1
      app.config.trashed.logger = Rails.logger
      app.config.trashed.statsd = connect_to_statsd(app.config.trashed.statsd)

      app.config.trashed.statsd_request_namespaces = lambda do |env|
        # Rails 3.2. Record request controller, action, and format.
        if controller = env['action_controller.instance']
          name, action, format = controller.controller_name, controller.action_name, controller.request.format.to_sym.to_s
          [ "Controllers.#{name}",
            "Formats.#{format}",
            "Actions.#{name}.#{action}.#{format}" ]
        end
      end

      hostname = `hostname -s`.chomp
      app.config.trashed.statsd_sampler_namespaces = lambda do |env|
        # Rails 3.2. Record hostname.
        [ "Hosts.#{hostname}" ]
      end
    end

    initializer 'trashed.middleware', :after => 'trashed', :before => 'trashed.newrelic' do |app|
      app.middleware.insert 0, Trashed::Rack::MeasureResourceUsage, app.config.trashed
    end

    initializer 'trashed.newrelic', :after => 'newrelic_rpm.start_plugin' do |app|
      if defined?(NewRelic::Control) && NewRelic::Control.instance.agent_enabled?
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
