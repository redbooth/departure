module PerconaMigrator
  class CliGenerator
    BASE_COMMAND = 'pt-online-schema-change'
    BASE_OPTIONS = %w(
      --execute
      --statistics
      --recursion-method=none
      --alter-foreign-keys-method=auto
    )

    # Constructor
    #
    # @param statements [Array] parsed perconas statements
    # @param table_name [String]
    # @param connection_data [Hash]
    def initialize(statements, table_name, connection_data)
      @statements = statements
      @table_name = table_name
      @connection_data = connection_data
    end

    # Generates the percona command. Fills all the connection credentials from
    # the current AR connection, but that can amended via ENV-vars:
    # PERCONA_DB_HOST, PERCONA_DB_USER, PERCONA_DB_PASSWORD, PERCONA_DB_NAME
    # Table name can't not be amended, it populates automatically from the
    # migration data
    def generate
      init_base_command
      add_connection_details
      add_alter_statement
      prepare_output
    end

    private

    attr_reader :statements, :table_name, :connection_data

    def init_base_command
      @command = [BASE_COMMAND, BASE_OPTIONS.join(' ')]
    end

    def add_alter_statement
      parsed_statements = statements.gsub(/ALTER TABLE `(\w+)` /, '')
      @command.push("--alter \"#{parsed_statements}\"")
    end

    def add_connection_details
      @command.push("-h #{host}")
      @command.push("-u #{user}")
      @command.push("-p #{password}") if password.present?
      @command.push("D=#{database},t=#{table_name}")
    end

    # Escapes all the backticks to not create new shells after pasting into
    # terminal
    def prepare_output
      @command.join(' ').gsub('`','\\\`')
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
