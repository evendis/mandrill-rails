#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec'
require 'rspec/core/rake_task'

desc "Run all RSpec test examples"
RSpec::Core::RakeTask.new do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task :default => :spec

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mandrill-rails"
  rdoc.rdoc_files.include('README*', 'lib/**/*.rb')
end
