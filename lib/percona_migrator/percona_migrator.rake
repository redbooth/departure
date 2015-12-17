# Disables ddl migrations ran with `db:migrate:*`
# in environments that have Percona Toolkit installed
task warn_in_production: :environment do
  percona_disabled = (ENV['PERCONA_TOOLKIT'].nil? || ENV['PERCONA_TOOLKIT'] == 'false')
  non_ddl_migration = !PerconaMigrator.lhm_migration?(ENV['VERSION'].to_i)

  next if percona_disabled || non_ddl_migration

  puts "\nWARNING: Regular DDL migrations are disabled in the current host. Use 'bundle exec rake db:percona_migrate:up VERSION=#{ENV['VERSION']}' instead"
  exit
end

%w(up down redo).each do |task|
  next unless Rake::Task.task_defined?("db:migrate:#{task}")
  Rake::Task["db:migrate:#{task}"].enhance [:warn_in_production]
end

namespace :db do
  namespace :migrate do
    desc 'Mark migration as down one. That will do not run the migration, just mark it'
    task mark_as_down: :environment do
      version = ensure_version
      PerconaMigrator.mark(:down, version)
    end

    desc 'Mark migration as up one. That will do not run the migration, just mark it'
    task mark_as_up: :environment do
      version = ensure_version
      PerconaMigrator.mark(:up, version)
    end
  end

  namespace :percona_migrate do
    desc 'Parse the migration\'s up method and generate corresponding command for percona tool'
    task up: :environment do
      ensure_multiplexer!
      version = ensure_version
      PerconaMigrator.migrate(version, :up)
    end

    desc 'Parse the migration\'s down method and generate corresponding command for percona tool'
    task down: :environment do
      ensure_multiplexer!
      version = ensure_version
      PerconaMigrator.migrate(version, :down)
    end
  end

  def ensure_version
    version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
    raise 'VERSION is required' unless version
    version
  end

  def ensure_multiplexer!
    return if ENV['TMUX'] || ENV['TERM'].include?('screen')
    raise "Please use screen or tmux to run migrations"
  end
end
