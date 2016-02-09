require 'byebug'
require 'active_record/connection_adapters/abstract_mysql_adapter'
require 'active_record/connection_adapters/statement_pool'
require 'active_record/connection_adapters/mysql2_adapter'
require 'percona_migrator'

module ActiveRecord
  class Base
    # Establishes a connection to the database that's used by all Active Record objects.
    def self.percona_connection(config)
      connection = mysql2_connection(config)
      client = connection.raw_connection

      connection_options = { mysql_adapter: connection }

      ConnectionAdapters::PerconaMigratorAdapter.new(client, logger, connection_options, config)
    end
  end

  module ConnectionAdapters
    class PerconaMigratorAdapter < AbstractMysqlAdapter

      class Column < AbstractMysqlAdapter::Column
        def adapter
          PerconaMigratorAdapter
        end
      end

      extend Forwardable

      ADAPTER_NAME = 'Percona'.freeze

      def_delegators :mysql_adapter, :tables, :select_values

      def initialize(connection, logger, connection_options, config)
        super
        @mysql_adapter = connection_options[:mysql_adapter]
        @config = config
        @logger = logger
      end

      def supports_migrations?
        true
      end

      def each_hash(result)
        mysql_adapter.each_hash(result)
      end

      def new_column(field, default, type, null, collation)
        Column.new(field, default, type, null, collation)
      end

      # TODO: Inject cli_generator and runner
      def add_column(table_name, column_name, type, options = {})
        super
        command = PerconaMigrator::CliGenerator.generate(@sql, table_name, config)
        PerconaMigrator::Runner.execute(command, logger)
      end

      # Used as a result of calling all of the schema statements: add_column,
      # remove_column, etc.
      def execute(sql, name = nil)
        @sql = sql
        true
      end

      def execute_and_free(sql, name = nil)
        yield mysql_adapter.execute(sql, name)
      end

      # TODO: We'll probably need to differentiate the delete statements that
      # came from a change in schema_migrations from those that come from the
      # migration itself
      def exec_delete(sql, name, binds)
        mysql_adapter.exec_delete(sql, name, binds)
      end

      def exec_query(sql, name, binds)
        mysql_adapter.exec_query(sql, :skip_logging, binds)
      end

      private

      attr_reader :mysql_adapter, :config, :logger
    end
  end
end
