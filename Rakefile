require 'rake/testtask'

desc 'Default: run tests'
task :default => :test

desc 'Run tests'
Rake::TestTask.new :test do |t|
  t.libs << 'test/lib'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end
