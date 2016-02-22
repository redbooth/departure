require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require './configuration'
require './test_database'
require 'percona_migrator/schema_migration'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :db do
  desc 'Create the test database'
  task :create do
    config = Configuration.new
    TestDatabase.new(config).create_test_database
  end
end
