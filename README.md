## Trashed
# Keep an eye on resource usage.


 - Logs per-request object counts, heap growth, and GC time.
 - Sends periodic resource usage snapshots to StatsD & NewRelic.
 - Requires Ruby 1.9 or REE.


## Setup

### Rails 3

On Rails 3, add this to the top of `config/application.rb`:

    require 'trashed/railtie'

And in the body of your app config:

    module YourApp
      class Application < Rails::Application
        config.trashed[:statsd] = YourApp.statsd


### Rails 2

On Rails 2, add the middleware to `config/environment.rb`:

    Rails::Initializer.run do |config|
      config.middleware.use Trashed::Rack::MeasureResourceUsage, :statsd => YourApp.statsd

And set up the sampler in `config/initializers/trashed.rb`:

    Trashed::Newrelic.sample Trashed::ResourceUsage, :statsd => YourApp.statsd
