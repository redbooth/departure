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

    ActiveRecord::Base.establish_connection(
      adapter: 'percona',
      host: 'localhost',
      username: config['username'],
      password: config['password'],
      database: 'percona_migrator_test'
    )

    TestDatabase.new(config).create
  end
end
