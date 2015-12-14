require 'lhm'

module PerconaMigrator
  class Migrator
    attr_reader :migration, :direction

    # Migrator's entrypoint. Runs the parsing and command generation
    #
    # @param version [Integer] migration version to parse
    # @param direction [Symbol] :up or :down
    # @return [String] Percona's migration command to paste
    def self.migrate(version, direction)
      new(version, direction).migrate
    end

    def self.get_migration(version)
      migrations_paths = ActiveRecord::Migrator.migrations_paths
      migrations = ActiveRecord::Migrator.migrations(migrations_paths)
      migrations.detect { |m| m.version == version }
    end

    def initialize(version, direction)
      @direction = direction
      initialize_migration(version)
    end

    def migrate
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        set_connection_to_migration(connection)
        generate_command(migration_results, connection)
      end
    end

    private

    # Finds the migration and gets the initialized migration class
    #
    # @param version [Integer] migration version to parse
    def initialize_migration(version)
      migration_proxy = self.class.get_migration(version)
      @migration = migration_proxy.send(:migration)
    end

    # Sets migration connection to ones from the pool
    # Migration (LHM) needs it to populate internal data about the columns in the DB
    #
    # @param connection [ActiveRecord::Connection]
    def set_connection_to_migration(connection)
      migration.instance_variable_set("@connection", connection)
    end

    # Runs the migration with patched LHM version and unpatch it afterwards
    def migration_results
      patch_lhm
      results = migration.send(direction)
      unpatch_lhm
      results
    end

    # Monkeypatch LHM not to run a migration, but return the parsed statements
    # Refinements will not work here because LHM is a module and it can't be refined
    def patch_lhm
      ::Lhm.module_eval do
        alias orig_change_table change_table
        def change_table(table_name, options = {}, &block)
          origin = ::Lhm::Table.parse(table_name, connection)
          invoker = ::Lhm::Invoker.new(origin, connection)
          block.call(invoker.migrator)
          {
            table_name: table_name,
            statements: invoker.migrator.statements
          }
        end
      end
    end

    def unpatch_lhm
      ::Lhm.module_eval do
        alias change_table orig_change_table
        remove_method(:orig_change_table)
      end
    end

    # Gets the LHM statemens, parses them and runs through command generator
    #
    # @param results [Array] LHM statements
    # @param connection [ActiveRecord::Connection]
    def generate_command(results, connection)
      statements = parse_migration_results_to_percona(results)
      connection_config = connection.instance_variable_get("@config")
      CliGenerator.generate(statements, results[:table_name], connection_config)
    end

    # Parses LHM statements into Percona ones.
    #
    # @param results [Hash] LHM working results
    def parse_migration_results_to_percona(results)
      LhmParser.parse(results[:statements])
    end
  end
end
