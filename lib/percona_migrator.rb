require 'active_record'
require 'active_support/all'
require 'percona_migrator/version'
require 'percona_migrator/migrator'
require 'percona_migrator/lhm_parser'
require 'percona_migrator/cli_generator'

module PerconaMigrator
  module_function

  # Runs the Percona Migrator
  #
  # @param version [Integer] migration version to parse
  # @param direction [Symbol] :up or :down
  # @return [String] Percona's migration command to paste
  def migrate(version, direction)
    raise 'Passed non-lhm migration for parsing' unless lhm_migration?(version)
    "#{Migrator.migrate(version, direction)} && #{mark_as_up_task(version)}"
  end

  # Checks if specified migration uses LHM
  #
  # @param version [Integer] migration version
  # @return [Boolean]
  def lhm_migration?(version)
    migration = Migrator.get_migration(version)
    !!(File.open(migration.filename).read =~ /Lhm\.change_table/)
  end

  # Returns the full `db:migrate:mark_as_up` command for the given version as
  # an String to be copy pasted
  #
  # @return [String]
  def mark_as_up_task(version)
    "bundle exec rake db:migrate:mark_as_up VERSION=#{version}"
  end
end
