require 'open3'

module PerconaMigrator
  class Error < StandardError; end

  # Used when for whatever reason we couldn't get the spawned process'
  # status.
  class NoStatusError < Error
    def message
      'Status could not be retrieved'.freeze
    end
  end

  # Used when the spawned process failed by receiving a signal.
  # pt-online-schema-change returns "SIGSEGV (signal 11)" on failures.
  class SignalError < Error
    attr_reader :status

    # Constructor
    #
    # @param status [Process::Status]
    def initialize(status)
      super
      @status = status
    end

    def message
      status.to_s
    end
  end

  class CommandNotFoundError < Error
    def message
      'Please install pt-online-schema-change. Check: https://www.percona.com/doc/percona-toolkit for further details'
    end
  end

  # It executes pt-online-schema-change commands in a new process and gets its
  # output and status
  class Runner
    COMMAND_NOT_FOUND = 127

    NONE = "\e[0m"
    CYAN = "\e[38;5;86m"
    GREEN = "\e[32m"

    # Constructor
    #
    # @param logger [IO]
    def initialize(logger, cli_generator, mysql_adapter)
      @logger = logger
      @cli_generator = cli_generator
      @mysql_adapter = mysql_adapter
      @status = nil
    end

    def query(sql)
      if alter_statement?(sql)
        command = cli_generator.parse_statement(sql)
        execute(command)
      else
        mysql_adapter.execute(sql)
      end
    end

    # Runs and logs the given command
    #
    # @param command [String]
    # @return [Boolean]
    def execute(command)
      @command = command
      logging { run_command }
      status
    end

    private

    attr_reader :command, :logger, :status, :cli_generator, :mysql_adapter

    # Checks whether the sql statement is an ALTER TABLE
    #
    # @param sql [String]
    # @return [Boolean]
    def alter_statement?(sql)
      sql =~ /alter table/i
    end

    # Logs the start and end of the execution
    #
    # @yield
    def logging
      log_started
      yield
      log_finished
    end

    # TODO: log as a migration logger subitem
    #
    # Logs when the execution started
    def log_started
      logger.info "\n#{CYAN}-- #{command}#{NONE}\n\n"
    end

    # Executes the command outputing any errors
    #
    # @raise [NoStatusError] if the spawned process' status can't be retrieved
    # @raise [SignalError] if the spawned process receives a signal
    # @raise [CommandNotFoundError] if pt-online-schema-change can't be found
    def run_command
      message = nil
      Open3.popen3(command) do |_stdin, stdout, stderr, waith_thr|
        @status = waith_thr.value
        message = stderr.read
        logger.info(stdout.read)
      end

      raise NoStatusError if status.nil?
      raise SignalError.new(status) if status.signaled?
      raise CommandNotFoundError if status.exitstatus == COMMAND_NOT_FOUND

      raise Error, message unless status.success?
    end

    # Logs the status of the execution once it's finished. At this point we
    # know it's a success
    def log_finished
      logger.info("\n#{GREEN}Done!#{NONE}")
    end
  end
end
