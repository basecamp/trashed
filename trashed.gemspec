Gem::Specification.new do |s|
  s.name      = 'trashed'
  s.version   = '3.2.7'
  s.license   = 'MIT'
  s.summary   = 'Rack request GC stats => logs + StatsD'
  s.description = 'Each Rack request eats up time, objects, and GC. Report usage to logs and StatsD.'

  s.homepage  = 'https://github.com/basecamp/trashed'
  s.author    = 'Jeremy Daer'
  s.email     = 'jeremydaer@gmail.com'

  s.add_runtime_dependency 'statsd-ruby', '~> 1.1'

  s.add_development_dependency 'rake', '~> 10'
  s.add_development_dependency 'minitest', '~> 5.3'

  root = File.dirname(__FILE__)
  s.files = [ "#{root}/init.rb" ] + Dir["#{root}/lib/**/*"]
end
