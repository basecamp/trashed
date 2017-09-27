require 'rails/railtie'
require 'trashed/reporter'

module Trashed
  class Railtie < ::Rails::Railtie
    config.trashed = Trashed::Reporter.new

    initializer 'trashed' do |app|
      require 'statsd'

      app.config.trashed.logger ||= Rails.logger
      Periodic.new config.trashed
    end

  end
end
