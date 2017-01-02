require 'percona_migrator/dsn'
require 'percona_migrator/option'
require 'percona_migrator/alter_argument'
require 'percona_migrator/connection_details'
require 'percona_migrator/user_options'

module PerconaMigrator

  # Generates the equivalent Percona's pt-online-schema-change command to the
  # given SQL statement
  #
  # --no-check-alter is used to allow running CHANGE COLUMN statements. For
  #   more details, check: www.percona.com/doc/percona-toolkit/2.2/pt-online-schema-change.html#cmdoption-pt-online-schema-change--[no]check-alter
  #
  class CliGenerator
    BASE_COMMAND = 'pt-online-schema-change'
    DEFAULT_OPTIONS = Set.new(
      [
        Option.new('execute'),
        Option.new('statistics'),
        Option.new('recursion-method', 'none'),
        Option.new('alter-foreign-keys-method', 'auto'),
        Option.new('no-check-alter')
      ]
    ).freeze

    # TODO: Better doc.
    #
    # Constructor. Specify any arguments to pass to pt-online-schema-change
    # passing the PERCONA_ARGS env var when executing the migration
    #
    # @param connection_data [Hash]
    def initialize(connection_details)
      @connection_details = connection_details
      @command = [BASE_COMMAND, connection_details.to_s]
    end

    # Generates the percona command. Fills all the connection credentials from
    # the current AR connection, but that can be amended via ENV-vars:
    # PERCONA_DB_HOST, PERCONA_DB_USER, PERCONA_DB_PASSWORD, PERCONA_DB_NAME
    # Table name can't not be amended, it populates automatically from the
    # migration data
    #
    # @param table_name [String]
    # @param statement [String] MySQL statement
    # @return [String]
    def generate(table_name, statement)
      alter_argument = AlterArgument.new(statement)
      dsn = DSN.new(connection_details.database, table_name)

      "#{self} #{dsn} #{alter_argument}"
    end

    # Generates the percona command for a raw MySQL statement. Fills all the
    # connection credentials from the current AR connection, but that can
    # amended via ENV-vars: PERCONA_DB_HOST, PERCONA_DB_USER,
    # PERCONA_DB_PASSWORD, PERCONA_DB_NAME Table name can't not be amended, it
    # populates automatically from the migration data
    #
    # @param statement [String] MySQL statement
    # @return [String]
    def parse_statement(statement)
      alter_argument = AlterArgument.new(statement)
      dsn = DSN.new(connection_details.database, alter_argument.table_name)

      "#{self} #{dsn} #{alter_argument}"
    end

    private

    attr_reader :connection_details, :command

    # Returns the command as a string that can be executed in a shell
    #
    # @return [String]
    def to_s
      "#{command.join(' ')} #{all_options.join(' ')}"
    end

    # Returns all the arguments to execute pt-online-schema-change with
    #
    # @return [Array]
    def all_options
      user_options = UserOptions.new
      user_options.merge(DEFAULT_OPTIONS).to_a
    end
  end
end
