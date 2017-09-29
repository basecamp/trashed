require 'rails/railtie'
require 'barnes/reporter'

module Barnes
  class Railtie < ::Rails::Railtie
    config.barnes = Barnes::Reporter.new

    initializer 'barnes' do |app|
      require 'statsd'

      app.config.barnes.logger ||= Rails.logger
      Periodic.new config.barnes
    end

  end
end
