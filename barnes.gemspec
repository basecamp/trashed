Gem::Specification.new do |s|
  s.name      = 'barnes'
  s.version   = '0.0.1'
  s.license   = 'MIT'
  s.summary   = 'Ruby GC stats => StatsD'
  s.description = 'Report GC usage data to StatsD.'

  s.homepage  = 'https://github.com/heroku/barnes'
  s.author    = 'APG'
  s.email     = 'agwozdziewycz@salesforce.com'

  s.add_runtime_dependency 'statsd-ruby', '~> 1.1'
  s.required_ruby_version = '>= 2.2.0'

  s.add_development_dependency 'rake', '~> 10'
  s.add_development_dependency 'minitest', '~> 5.3'

  root = File.dirname(__FILE__)
  s.files = [ "#{root}/init.rb" ] + Dir["#{root}/lib/**/*"]
end
