module PerconaMigrator
  module CliGenerator
    BASE_COMMAND = 'pt-online-schema-change'
    BASE_OPTIONS = %w(
      --execute
      --recursion-method=none
      --alter-foreign-keys-method=auto
    )

    module_function

    # Generates the percona command
    # Fills all the connection credentials from the current AR connection,
    # but that can amended via ENV-vars: PERCONA_DB_HOST, PERCONA_DB_USER, PERCONA_DB_PASSWORD, PERCONA_DB_NAME
    # Table name could not be amended, it populates automatically from the migration data
    #
    # @param statements [Array] parsed perconas statements
    # @param table_name [String]
    # @param connection_data [Hash]
    def generate(statements, table_name, connection_data)
      init_base_command
      add_connection_details(table_name, connection_data)
      add_alter_statement(statements)
      prepare_output
    end

    def init_base_command
      @command = [BASE_COMMAND, BASE_OPTIONS.join(' ')]
    end

    def add_alter_statement(statements)
      parsed_statements = statements
      parsed_statements = %Q[#{statements.join(', ')}] if statements.is_a?(Array)
      @command.push("--alter \"#{parsed_statements}\"")
    end

    def add_connection_details(table_name, connection_data)
      @command.push("-h #{ENV['PERCONA_DB_HOST'] || connection_data[:host] || 'localhost'}")
      @command.push("-u #{ENV['PERCONA_DB_USER'] || connection_data[:username]}")
      add_password(connection_data)
      @command.push("D=#{ENV['PERCONA_DB_NAME'] || connection_data[:database]},t=#{table_name}")
    end

    def add_password(connection_data)
      password = ENV['PERCONA_DB_PASSWORD'] || connection_data[:password]
      @command.push("-p #{password}") if password.present?
    end

    # Escapes all the backticks to not create new shells after pasting into terminal
    def prepare_output
      @command.join(' ').gsub('`','\\\`')
    end
  end
end
