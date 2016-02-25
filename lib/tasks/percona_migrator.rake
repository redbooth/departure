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
