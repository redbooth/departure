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
      mysql2_connection = mysql2_connection(config)

      cli_generator = PerconaMigrator::CliGenerator.new(config)
      runner = PerconaMigrator::Runner.new(
        logger,
        cli_generator,
        mysql2_connection
      )

      config.merge!(
        logger: logger,
        runner: runner,
        cli_generator: cli_generator
      )

      connection_options = { mysql_adapter: mysql2_connection }

      ConnectionAdapters::PerconaMigratorAdapter.new(
        runner,
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
        :exec_insert, :exec_query, :last_inserted_id, :select

      def initialize(connection, logger, connection_options, config)
        super
        @mysql_adapter = connection_options[:mysql_adapter]
        @logger = logger
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

      # Adds a new index to the table
      #
      # @param table_name [String, Symbol]
      # @param column_name [String, Symbol]
      # @param options [Hash] optional
      def add_index(table_name, column_name, options = {})
        index_name, index_type, index_columns, index_options = add_index_options(table_name, column_name, options)
        execute "ALTER TABLE #{quote_table_name(table_name)} ADD #{index_type} INDEX #{quote_column_name(index_name)} (#{index_columns})#{index_options}"
      end

      # Remove the given index from the table.
      #
      # @param table_name [String, Symbol]
      # @param options [Hash] optional
      def remove_index(table_name, options = {})
        index_name = index_name_for_remove(table_name, options)
        execute "ALTER TABLE #{quote_table_name(table_name)} DROP INDEX #{quote_column_name(index_name)}"
      end

      # Executes the passed statement through pt-online-schema-change if it's
      # an alter statement, or through the mysql adapter otherwise
      #
      # @param sql [String]
      # @param name [String]
      def percona_execute(sql, name)
        if alter_statement?(sql)
          command = cli_generator.parse_statement(sql)
          @connection.execute(command)
        else
          mysql_adapter.execute(sql, name)
        end
      end

      # This abstract method leaves up to the connection adapter freeing the
      # result, if it needs to. Check out: https://github.com/rails/rails/blob/330c6af05c8b188eb072afa56c07d5fe15767c3c/activerecord/lib/active_record/connection_adapters/abstract_mysql_adapter.rb#L247
      #
      # @param sql [String]
      # @param name [String] optional
      def execute_and_free(sql, name = nil)
        yield mysql_adapter.execute(sql, name)
      end

      def error_number(exception)
      end

      private

      attr_reader :mysql_adapter, :logger, :runner, :cli_generator

      # Checks whether the sql statement is an ALTER TABLE
      #
      # @param sql [String]
      # @return [Boolean]
      def alter_statement?(sql)
        sql =~ /alter table/i
      end
    end
  end
end
