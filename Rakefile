#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rspec/core/rake_task'

task :default => :spec
if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  task :default => :appraisal
end
RSpec::Core::RakeTask.new('spec')
