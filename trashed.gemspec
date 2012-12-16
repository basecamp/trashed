Gem::Specification.new do |s|
  s.name      = 'trashed'
  s.version   = '2.0.5'
  s.author    = 'Jeremy Kemper'
  s.email     = 'jeremy@bitsweat.net'
  s.homepage  = 'https://github.com/37signals/trashed'
  s.summary   = 'Keep tabs on Ruby garbage collection: object counts, allocated bytes, GC time.'

  s.add_dependency 'statsd-ruby', '>= 0.4'

  s.files = Dir["#{File.dirname(__FILE__)}/**/*"]
end
