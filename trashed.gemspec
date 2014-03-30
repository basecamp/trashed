Gem::Specification.new do |s|
  s.name      = 'trashed'
  s.version   = '3.0.1'
  s.author    = 'Jeremy Kemper'
  s.email     = 'jeremykemper@gmail.com'
  s.homepage  = 'https://github.com/basecamp/trashed'
  s.summary   = 'Report per-request object allocations, GC time, and more to StatsD'

  s.add_runtime_dependency 'statsd-ruby', '~> 1.1'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest', '~> 5.3'

  root = File.dirname(__FILE__)
  s.files = [ "#{root}/init.rb" ] + Dir["#{root}/lib/**/*"]
end
