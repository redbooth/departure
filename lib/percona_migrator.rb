require 'active_record'
require 'active_support/all'
require 'percona_migrator/version'
require 'percona_migrator/migrator'
require 'percona_migrator/lhm_parser'
require 'percona_migrator/cli_generator'
require 'percona_migrator/railtie'
require 'percona_migrator/schema_migration'

module PerconaMigrator
  module_function

  NONE = "\e[0m"
  CYAN = "\e[38;5;86m"
  GREEN = "\e[32m"
  RED = "\e[31m"

  # Runs the Percona Migrator
  #
  # @param version [Integer] migration version to parse
  # @param direction [Symbol] :up or :down
  # @return [String] Percona's migration command to paste
  def migrate(version, direction, logger = $stdout)
    raise 'Passed non-lhm migration for parsing' unless lhm_migration?(version)

    migration_command = Migrator.migrate(version, direction)

    ok = run(migration_command, logger)
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
      PerconaMigrator::SchemaMigration.create!(:version => version.to_s)
    elsif direction == :down
      PerconaMigrator::SchemaMigration.where(:version => version.to_s).delete_all
    end
  end

  # Runs and logs the given command
  #
  # @return [Boolean]
  def run(command, logger)
    logger.puts "\n#{CYAN}-- #{command}#{NONE}\n\n"
    status = Kernel.system(command)
    logger.puts(status ? "\n#{GREEN}Done!#{NONE}" : "\n#{RED}Failed!#{NONE}")
    status
  end
end
