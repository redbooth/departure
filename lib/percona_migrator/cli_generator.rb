require 'percona_migrator/alter_argument'

module PerconaMigrator
  class DSN
    def initialize(database, table_name)
      @database = database
      @table_name = table_name
    end

    def to_s
      "D=#{database},t=#{table_name}"
    end

    private

    attr_reader :table_name, :database
  end

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
      dsn = DSN.new(database, table_name)
      alter_argument = AlterArgument.new(statement)

      "#{to_s} #{dsn} #{alter_argument}"
    end

    private

    attr_reader :connection_data

    def init_base_command
      @command = [BASE_COMMAND, BASE_OPTIONS.join(' ')]
    end

    def add_connection_details
      @command.push("-h #{host}")
      @command.push("-u #{user}")
      @command.push("-p #{password}") if password.present?
    end

    def to_s
      @command.join(' ')
    end

    def host
      ENV['PERCONA_DB_HOST'] || connection_data[:host] || 'localhost'
    end

    def user
      ENV['PERCONA_DB_USER'] || connection_data[:username]
    end

    def password
      ENV['PERCONA_DB_PASSWORD'] || connection_data[:password]
    end

    # TODO: Doesn't the abstract adapter already handle this somehow?
    def database
      ENV['PERCONA_DB_NAME'] || connection_data[:database]
    end
  end
end
