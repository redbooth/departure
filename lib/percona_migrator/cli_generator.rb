require 'percona_migrator/alter_argument'

module PerconaMigrator

  # Represents the 'DSN' argument of Percona's pt-online-schema-change
  # See https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html#dsn-options
  class DSN

    # Constructor
    #
    # @param database [String, Symbol]
    # @param table_name [String, Symbol]
    def initialize(database, table_name)
      @database = database
      @table_name = table_name
    end

    # Returns the pt-online-schema-change DSN string. See
    # https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html#dsn-options
    def to_s
      "D=#{database},t=#{table_name}"
    end

    private

    attr_reader :table_name, :database
  end

  # Generates the equivalent Percona's pt-online-schema-change command to the
  # given SQL statement
  class CliGenerator # Command
    BASE_COMMAND = 'pt-online-schema-change'
    BASE_OPTIONS = %w(
      --execute
      --statistics
      --recursion-method=none
      --alter-foreign-keys-method=auto
    )

    # Constructor
    #
    # @param connection_data [Hash]
    def initialize(connection_data)
      @connection_data = connection_data
      init_base_command
      add_connection_details
    end

    # Generates the percona command. Fills all the connection credentials from
    # the current AR connection, but that can amended via ENV-vars:
    # PERCONA_DB_HOST, PERCONA_DB_USER, PERCONA_DB_PASSWORD, PERCONA_DB_NAME
    # Table name can't not be amended, it populates automatically from the
    # migration data
    #
    # @param table_name [String]
    # @param statement [String] MySQL statement
    # @return [String]
    def generate(table_name, statement)
      alter_argument = AlterArgument.new(statement)
      dsn = DSN.new(database, table_name)

      "#{to_s} #{dsn} #{alter_argument}"
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
      dsn = DSN.new(database, alter_argument.table_name)

      "#{to_s} #{dsn} #{alter_argument}"
    end

    private

    attr_reader :connection_data

    # Sets up the command with its options
    def init_base_command
      @command = [BASE_COMMAND, BASE_OPTIONS.join(' ')]
    end

    # Adds the host, user and password, if present, to the command
    def add_connection_details
      @command.push("-h #{host}")
      @command.push("-u #{user}")
      @command.push("-p #{password}") if password.present?
    end

    # Returns the command as a string that can be executed in a shell
    #
    # @return [String]
    def to_s
      @command.join(' ')
    end

    # Returns the database host name, defaulting to localhost. If PERCONA_DB_HOST
    # is passed its value will be used instead
    #
    # @return [String]
    def host
      ENV['PERCONA_DB_HOST'] || connection_data[:host] || 'localhost'
    end

    # Returns the database user. If PERCONA_DB_USER is passed its value will be
    # used instead
    #
    # @return [String]
    def user
      ENV['PERCONA_DB_USER'] || connection_data[:username]
    end

    # Returns the database user's password. If PERCONA_DB_PASSWORD is passed its
    # value will be used instead
    #
    # @return [String]
    def password
      ENV['PERCONA_DB_PASSWORD'] || connection_data[:password]
    end

    # TODO: Doesn't the abstract adapter already handle this somehow?
    # Returns the database name. If PERCONA_DB_NAME is passed its value will be
    # used instead
    def database
      ENV['PERCONA_DB_NAME'] || connection_data[:database]
    end
  end
end
