## Trashed
# Keep an eye on resource usage.


 - Sends per-request object counts, heap growth, GC time, and more to StatsD.
 - Sends snapshots of resource usage, e.g. live String objects, to StatsD.
 - Supports new stuff: Rails 5.1 and latest Ruby 2.x features.
 - Supports old stuff: Rails 2/3/4, Ruby 1.9+, REE, Ruby 1.8 with RubyBench patches.

## Setup

### Rails 5

On Rails 5 (and Rails 3 and 4), add this to the top of `config/application.rb`:

    require 'trashed/railtie'

And in the body of your app config:

    module YourApp
      class Application < Rails::Application
        config.trashed.statsd = YourApp.statsd


### Rails 2

On Rails 2, add the middleware to `config/environment.rb`:

    Rails::Initializer.run do |config|
      reporter = Trashed::Reporter.new
      reporter.logger = Rails.logger
      reporter.statsd = YourApp.statsd

      config.middleware.use Trashed::Rack, reporter
    end


### Custom dimensions

You probably want stats per controller, action, right?

Set a `#timing_dimensions` lambda to return a list of dimensions to
qualify per-request measurements like time elapsed, GC time, objects
allocated, etc.

For example:
```ruby
config.trashed.timing_dimensions = ->(env) do
  # Rails 3, 4, and 5, set this. Other Rack endpoints won't have it.
  if controller = env['action_controller.instance']
    name    = controller.controller_name
    action  = controller.action_name
    format  = controller.rendered_format || :none
    variant = controller.request.variant || :none  # Rails 4.1+ only!

    [ :All,
      :"Controllers.#{name}",
      :"Actions.#{name}.#{action}.#{format}+#{variant}" ]
  end
end
```

Results in metrics like:
```
YourNamespace.All.Time.wall
YourNamespace.Controllers.SessionsController.Time.wall
YourNamespace.Actions.SessionsController.index.json+phone.Time.wall
```


Similarly, set a `#gauge_dimensions` lambda to return a list of dimensions to
qualify measurements which gauge current state, like heap slots used or total
number of live String objects.

For example:

```ruby
config.trashed.gauge_dimensions = ->(env) {
  [ :All,
    :"Stage.#{Rails.env}",
    :"Hosts.#{`hostname -s`.chomp}" ]
}
```

Results in metrics like:
```
YourNamespace.All.Objects.T_STRING
YourNamespace.Stage.production.Objects.T_STRING
YourNamespace.Hosts.host-001.Objects.T_STRING
```


### Version history

*3.2.8* (January 31, 2022)

* REE: Fix that GC.time is reported in microseconds instead of milliseconds

*3.2.7* (November 8, 2017)

* Ruby 1.8.7 compatibility

*3.2.6* (June 21, 2017)

* Mention Rails 5 support

*3.2.5* (Feb 26, 2015)

* Support Ruby 2.2 GC.stat naming, avoiding 2.1 warnings

*3.2.4* (July 25, 2014)

* Fix compatibility with Rails 3.x tagged logging - @calavera

*3.2.3* (June 23, 2014)

* Report CPU/Idle time in tenths of a percent

*3.2.2* (March 31, 2014)

* Reduce default sampling rates.
* Stop gauging all GC::Profiler data. Too noisy.
* Report gauge readings as StatsD timings.
* Support providing a Statsd::Batch since using Statsd#batch
  results in underfilled packets at low sample rates.
* Fix bug with sending arrays of timings to StatsD.
* Record GC timings in milliseconds.

*3.1.0* (March 30, 2014)

* Report percent CPU/idle time: Time.pct.cpu and Time.pct.idle.
* Measure out-of-band GC count, time, and stats. Only meaningful for
  single-threaded servers like Unicorn. But then again so is per-request
  GC monitoring.
* Support @tmm1's GC::OOB (https://github.com/tmm1/gctools).
* Measure time between GCs.
* Spiff up logger reports with more timings.
* Support Rails log tags on logged reports.
* Allow instruments' #start to set timings/gauges.

*3.0.1* (March 30, 2014)

* Sample requests to instrument based on StatsD sample rate.

*3.0.0* (March 29, 2014)

* Support new Ruby 2.0 and 2.1 GC stats.
* Gauge GC details with GC::Profiler.
* Performance rework. Faster, fewer allocations.
* Rework counters and gauges as instruments.
* Batch StatsD messages to decrease overhead on the server.
* Drop NewRelic samplers.

*2.0.5* (December 15, 2012)

* Relax outdated statsd-ruby dependency.

*2.0.0* (December 1, 2011)

* Rails 3 support.
* NewRelic samplers.

*1.0.0* (August 24, 2009)

* Initial release.
