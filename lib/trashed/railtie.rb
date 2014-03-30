require 'rails/railtie'
require 'trashed/rack'
require 'trashed/reporter'

module Trashed
  class Railtie < ::Rails::Railtie
    config.trashed = Trashed::Reporter.new

    initializer 'trashed' do |app|
      require 'statsd'

      app.config.trashed.sample_rate ||= 1.0
      app.config.trashed.logger ||= Rails.logger

      app.middleware.insert_after 'Rack::Runtime', Trashed::Rack, app.config.trashed
    end
  end
end
