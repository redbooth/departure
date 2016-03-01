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

      config.merge!(
        logger: logger,
        runner: PerconaMigrator::Runner.new(logger),
        cli_generator: PerconaMigrator::CliGenerator.new(config)
      )

      connection_options = { mysql_adapter: connection }

      ConnectionAdapters::PerconaMigratorAdapter.new(
        client,
        logger,
        connection_options,
        config
      )
    end
  end

  module ConnectionAdapters
    # It doesn't implement #create_table as this statement is harmless and
    # pretty fast. No need to do it with Percona
    class PerconaMigratorAdapter < AbstractMysqlAdapter

      class Column < AbstractMysqlAdapter::Column
        def adapter
          PerconaMigratorAdapter
        end
      end

      extend Forwardable

      ADAPTER_NAME = 'Percona'.freeze

      def_delegators :mysql_adapter, :tables, :select_values, :exec_delete,
        :exec_insert, :exec_query, :last_inserted_id, :select

      def initialize(connection, logger, connection_options, config)
        super
        @mysql_adapter = connection_options[:mysql_adapter]
        @logger = logger
        @runner = config[:runner]
        @cli_generator = config[:cli_generator]
      end

      # Returns true, as this adapter supports migrations
      def supports_migrations?
        true
      end

      # Delegates #each_hash to the mysql adapter
      #
      # @param result [Mysql2::Result]
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

      # Adds a new column to the named table
      #
      # @param table_name [String, Symbol]
      # @param column_name [String, Symbol]
      # @param type [Symbol]
      # @param options [Hash] optional
      def add_column(table_name, column_name, type, options = {})
        super
        command = cli_generator.generate(table_name, @sql)
        runner.execute(command)
      end

      # Removes the column(s) from the table definition
      #
      # @param table_name [String, Symbol]
      # @param column_names [String, Symbol, Array<String>, Array<Symbol>]
      def remove_column(table_name, *column_names)
        super
        command = cli_generator.generate(table_name, @sql)
        runner.execute(command)
      end

      # Adds a new index to the table
      #
      # @param table_name [String, Symbol]
      # @param column_name [String, Symbol]
      # @param options [Hash] optional
      def add_index(table_name, column_name, options = {})
        index_name, index_type, index_columns, index_options = add_index_options(table_name, column_name, options)
        execute "ADD #{index_type} INDEX #{quote_column_name(index_name)} (#{index_columns})#{index_options}"

        command = cli_generator.generate(table_name, @sql)
        runner.execute(command)
      end

      # Remove the given index from the table.
      #
      # @param table_name [String, Symbol]
      # @param options [Hash] optional
      def remove_index(table_name, options = {})
        index_name = index_name_for_remove(table_name, options)
        execute "DROP INDEX #{quote_column_name(index_name)}"

        command = cli_generator.generate(table_name, @sql)
        runner.execute(command)
      end

      # Records the SQL statement to be executed. This is used to then delegate
      # the execution to Percona's pt-online-schema-change.
      #
      # @param sql [String]
      # @param _name [String] optional
      def execute(sql, _name = nil)
        @sql = sql
        true
      end

      # This abstract method leaves up to the connection adapter freeing the
      # result, if it needs to. Check out: https://github.com/rails/rails/blob/330c6af05c8b188eb072afa56c07d5fe15767c3c/activerecord/lib/active_record/connection_adapters/abstract_mysql_adapter.rb#L247
      #
      # @param sql [String]
      # @param name [String] optional
      def execute_and_free(sql, name = nil)
        yield mysql_adapter.execute(sql, name)
      end

      private

      attr_reader :mysql_adapter, :logger, :runner, :cli_generator
    end
  end
end
