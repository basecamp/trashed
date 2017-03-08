require 'rails/railtie'
require 'trashed/rack'
require 'trashed/reporter'

module Trashed
  class Railtie < ::Rails::Railtie
    config.trashed = Trashed::Reporter::Aggregator.new

    # Middleware would like to emit tagged logs after Rails::Rack::Logger
    # pops its tags. Introduce this haxware to stash the tags in the Rack
    # env so we can reuse them later.
    class ExposeLoggerTagsToRackEnv
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env).tap do
          env['trashed.logger.tags'] = Array(Thread.current[:activesupport_tagged_logging_tags]).dup
        end
      end
    end

    initializer 'trashed' do |app|
      app.config.trashed.add_reporter Trashed::Reporter::Logger.new(Rails.logger)

      app.middleware.insert_after ::Rack::Runtime, Trashed::Rack, app.config.trashed
      app.middleware.insert_after ::Rails::Rack::Logger, ExposeLoggerTagsToRackEnv
    end
  end
end
