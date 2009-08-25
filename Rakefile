require 'rubygems'
require 'rubygems/specification'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

require "#{File.dirname(__FILE__)}/lib/trashed/version"

spec = Gem::Specification.new do |s|
  s.name = 'trashed'
  s.version = Trashed::VERSION
  s.platform = Gem::Platform::RUBY

  s.add_dependency 'activesupport', '>= 2.3.0'

  s.files = %w(MIT-LICENSE README) + Dir['lib/**/*']
  s.require_path = 'lib'
  s.has_rdoc = true

  s.homepage = 'http://github.com/37signals/trashed'
  s.summary = 'Keep tabs on expensive Ruby garbage collection. Supports NewRelic RPM and Rack.'

  s.author = 'Jeremy Kemper'
  s.email = 'jeremy@bitsweat.net'
end


desc 'Default: run unit tests'
task :default => :test

desc 'Run unit tests'
Rake::TestTask.new :test do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate RDoc documentation'
Rake::RDocTask.new :rdoc do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'Trashed'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('MIT-LICENSE')
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Spit out a gemspec'
task :gemspec do
  File.open('trashed.gemspec', 'w') { |file| file.puts spec.to_ruby }
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
end
