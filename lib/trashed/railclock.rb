require 'rails/railtie'
require 'trashed/periodic'
require 'trashed/reporter'

module Trashed
  class RailClockTie < ::Rails::Railtie
    config.trashed_periodic = Trashed::PeriodicReporter.new

    initializer 'trashed.periodic' do |app|
      require 'statsd'

      app.config.trashed_periodic.logger ||= Rails.logger

      Periodic.new config.trashed_periodic
    end
  end
end
