## Barnes - GC Statsd Reporter

A fork of [trashed](https://github.com/basecamp/trashed) focused on Ruby metrics for Heroku.

## Setup

### Rails 5

On Rails 5 (and Rails 3 and 4), add this to your Gemfile:

```
gem "barnes"
```

Then run:

```
$ bundle install
```

### Non-Rails

Add the gem to the Gemfile

```
gem "barnes"
```

Then run:

```
$ bundle install
```

In your application:


```ruby
require 'barnes'
```

Then you'll need to start the client with default values:

```ruby
Barnes.start
```

