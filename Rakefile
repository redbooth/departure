require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require './configuration'

config = Configuration.new

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

namespace :db do
  desc 'Create the test database'
  task :create do
    %x(mysql --user=#{config['username']} --password=#{config['password']} -e "CREATE DATABASE percona_migrator_test DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci")
    %x(mysql --user=#{config['username']} --password=#{config['password']} -e "USE percona_migrator_test; CREATE TABLE comments (id int(12) NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;")
  end
end
