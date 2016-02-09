require 'active_record'
require 'active_support/all'
require 'percona_migrator/version'
require 'percona_migrator/runner'
require 'percona_migrator/migrator'
require 'percona_migrator/lhm_parser'
require 'percona_migrator/cli_generator'
require 'percona_migrator/schema_migration'

module PerconaMigrator
  module_function

  # Runs the Percona Migrator
  #
  # @param version [Integer] migration version to parse
  # @param direction [Symbol] :up or :down
  # @return [String] Percona's migration command to paste
  def migrate(version, direction, logger = $stdout)
    raise 'Passed non-lhm migration for parsing' unless lhm_migration?(version)

    migration_command = Migrator.migrate(version, direction)

    ok = Runner.execute(migration_command, logger)
    mark(direction, version) if ok
    nil
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
  def mark(direction, version)
    if direction == :up
      SchemaMigration.create!(version: version.to_s)
    elsif direction == :down
      SchemaMigration.where(version: version.to_s).delete_all
    end
  end
end
