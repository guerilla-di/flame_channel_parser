# -*- ruby -*-

require 'rubygems'
require 'jeweler'
require './lib/flame_channel_parser'

Jeweler::Tasks.new do |gem|
  gem.version = FlameChannelParser::VERSION
  gem.name = "flame_channel_parser"
  gem.summary = "A parser/interpolator for Flame/Smoke animation curves"
  gem.description = "Reads and interpolates animation channels in IFFS setups"
  gem.email = "me@julik.nl"
  gem.homepage = "http://guerilla-di.org/flame-channel-parser/"
  gem.authors = ["Julik Tarkhanov"]
  gem.license = 'MIT'
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
desc "Run all tests"
Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

task :default => [ :test ]

# vim: syntax=ruby
