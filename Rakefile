# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "not-it"
  gem.homepage = "http://github.com/bsensale/not-it"
  gem.license = "MIT"
  gem.summary = %Q{tools for syncing pagerduty schedules to a google calendar}
  gem.description = %Q{Provides a wrapper around the pagerduty apis and google apis to keep a google calendar in sync}
  gem.email = "bsensale@brightcove.com"
  gem.authors = ["Brian Sensale"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'spec'
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new
