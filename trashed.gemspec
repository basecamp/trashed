Gem::Specification.new do |s|
  s.name      = 'trashed'
  s.version   = '1.0.0'
  s.author    = 'Jeremy Kemper'
  s.email     = 'jeremy@bitsweat.net'
  s.homepage  = 'https://github.com/37signals/trashed'
  s.summary   = 'Just enough JSON+HTTP to chat with ElasticSearch and manage schema migrations'
  s.summary   = 'Keep tabs on expensive Ruby garbage collection. Supports NewRelic RPM and Rack.'

  s.add_dependency 'activesupport', '>= 2.3.0'

  s.files = Dir["#{File.dirname(__FILE__)}/**/*"]
end
