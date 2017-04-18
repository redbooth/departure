require 'open3'

module Departure

  # It executes pt-online-schema-change commands in a new process and gets its
  # output and status
  class Runner
    COMMAND_NOT_FOUND = 127

    # Constructor
    #
    # @param logger [#say, #write]
    # @param cli_generator [CliGenerator]
    # @param mysql_adapter [ActiveRecord::ConnectionAdapter] it must implement
    #   #execute and #raw_connection
    def initialize(logger, cli_generator, mysql_adapter, config = Departure.configuration)
      @logger = logger
      @cli_generator = cli_generator
      @mysql_adapter = mysql_adapter
      @status = nil
      @config = config
    end

    # Executes the passed sql statement using pt-online-schema-change for ALTER
    # TABLE statements, or the specified mysql adapter otherwise.
    #
    # @param sql [String]
    def query(sql)
      if alter_statement?(sql)
        command = cli_generator.parse_statement(sql)
        execute(command)
      else
        mysql_adapter.execute(sql)
      end
    end

    # Returns the number of rows affected by the last UPDATE, DELETE or INSERT
    # statements
    #
    # @return [Integer]
    def affected_rows
      mysql_adapter.raw_connection.affected_rows
    end

    # TODO: rename it so we don't confuse it with AR's #execute
    # Runs and logs the given command
    #
    # @param command [String]
    # @return [Boolean]
    def execute(command)
      @command = command
      logging { run_command }
      validate_status
      status
    end

    private

    attr_reader :command, :logger, :status, :cli_generator, :mysql_adapter, :config

    # Checks whether the sql statement is an ALTER TABLE
    #
    # @param sql [String]
    # @return [Boolean]
    def alter_statement?(sql)
      sql =~ /\Aalter table/i
    end

    # Logs the start and end of the execution
    #
    # @yield
    def logging
      log_deprecations
      log_started
      yield
      log_finished
    end

    def log_deprecations
      logger.write("\n")
      logger.write("[DEPRECATION] This gem has been renamed to Departure and will no longer be supported. Please switch to Departure as soon as possible.")
    end

    # Logs when the execution started
    def log_started
      logger.write("\n")
      logger.say("Running #{command}\n\n", true)
    end

    # Executes the command and prints its output to the stdout
    def run_command
      Open3.popen3("#{command} 2> #{error_log_path}") do |_stdin, stdout, _stderr, waith_thr|
        begin
          loop do
            IO.select([stdout])
            data = stdout.read_nonblock(8)
            logger.write_no_newline(data)
          end
        rescue EOFError
          # noop
        ensure
          @status = waith_thr.value
        end
      end
    end

    # Validates the status of the execution
    #
    # @raise [NoStatusError] if the spawned process' status can't be retrieved
    # @raise [SignalError] if the spawned process received a signal
    # @raise [CommandNotFoundError] if pt-online-schema-change can't be found
    def validate_status
      raise SignalError.new(status) if status.signaled?
      raise CommandNotFoundError if status.exitstatus == COMMAND_NOT_FOUND
      raise Error, error_message unless status.success?
    end

    # Prints a line break to keep the logs separate from the execution time
    # print by the migration
    def log_finished
      logger.write("\n")
    end

    # The path where the percona toolkit stderr will be written
    #
    # @return [String]
    def error_log_path
      config.error_log_path
    end

    # @return [String]
    def error_message
      File.read(error_log_path)
    end
  end
end
