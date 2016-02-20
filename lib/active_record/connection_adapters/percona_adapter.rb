require 'active_record/connection_adapters/abstract_mysql_adapter'
require 'active_record/connection_adapters/statement_pool'
require 'active_record/connection_adapters/mysql2_adapter'
require 'percona_migrator'
require 'forwardable'

module ActiveRecord
  class Base
    # Establishes a connection to the database that's used by all Active
    # Record objects.
    def self.percona_connection(config)
      connection = mysql2_connection(config)
      client = connection.raw_connection
      logger = config[:logger]

      connection_options = {
        mysql_adapter: connection,
        runner: PerconaMigrator::Runner.new(logger)
      }

      ConnectionAdapters::PerconaMigratorAdapter.new(
        client,
        logger,
        connection_options,
        config
      )
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

      def_delegators :mysql_adapter, :tables, :select_values, :exec_delete,
        :exec_insert, :exec_query, :last_inserted_id

      def initialize(connection, logger, connection_options, config)
        super
        @mysql_adapter = connection_options[:mysql_adapter]
        @config = config
        @logger = logger
        @runner = connection_options[:runner]
        @cli_generator = PerconaMigrator::CliGenerator.new(config)
      end

      def supports_migrations?
        true
      end

      def each_hash(result)
        if block_given?
          mysql_adapter.each_hash(result, &Proc.new)
        else
          mysql_adapter.each_hash(result)
        end
      end

      def new_column(field, default, type, null, collation)
        Column.new(field, default, type, null, collation)
      end

      def add_column(table_name, column_name, type, options = {})
        super
        command = cli_generator.generate(table_name, @sql)
        runner.execute(command)
      end

      def remove_column(table_name, *column_names)
        super
        command = cli_generator.generate(table_name, @sql)
        runner.execute(command)
      end

      # TODO: Implement all methods in ConnectionAdapters::SchemaStatements?
      # It must use ALTER TABLE syntax, so the SchemaStatements#add_index doesn't work for pt-online-schema-change
      def add_index(table_name, column_name, options = {})
        index_name, index_type, index_columns, index_options = add_index_options(table_name, column_name, options)
        execute "ADD #{index_type} INDEX #{quote_column_name(index_name)} (#{index_columns})#{index_options}"

        command = cli_generator.generate(table_name, @sql)
        runner.execute(command)
      end

      # Copied from SchemaStatments#remove_index
      def remove_index(table_name, options = {})
        index_name = index_name_for_remove(table_name, options)
        execute "DROP INDEX #{quote_column_name(index_name)}"

        command = cli_generator.generate(table_name, @sql)
        runner.execute(command)
      end

      # TODO: Prepared statements?
      # TODO: How does this play with executing raw SQL from a migration? You
      # normally use #execute Used as a result of calling all of the schema
      # statements: add_column,
      # remove_column, etc.
      def execute(sql, _name = nil)
        @sql = sql
        true
      end

      def execute_and_free(sql, name = nil)
        yield mysql_adapter.execute(sql, name)
      end

      private

      attr_reader :mysql_adapter, :config, :logger, :runner, :cli_generator
    end
  end
end
