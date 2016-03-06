require 'open3'

module PerconaMigrator

  # It executes pt-online-schema-change commands in a new process and gets its
  # output and status
  class Runner

    NONE = "\e[0m"
    CYAN = "\e[38;5;86m"
    GREEN = "\e[32m"
    RED = "\e[31m"

    # Executes the given command printing the output to the logger
    #
    # @param command [String]
    # @param logger [IO]
    def self.execute(command, logger)
      new(command, logger).execute
    end

    # Constructor
    #
    # @param logger [IO]
    def initialize(logger)
      @logger = logger
      @status = nil
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

    attr_reader :command, :logger, :status

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
    # @raise [Errno::ENOENT] if pt-online-schema-change can't be found
    def run_command
      Open3.popen3(command) do |_stdin, stdout, _stderr, waith_thr|
        @status = waith_thr.value
        logger.info stdout.read
      end

      if status.nil?
        Kernel.warn("Error running '#{command}': status could not be retrieved")
      end

      if status && status.signaled?
        Kernel.warn("Error running '#{command}': #{status}")
      end

    rescue Errno::ENOENT
      raise Errno::ENOENT, "Please install pt-online-schema-change. Check: https://www.percona.com/doc/percona-toolkit"
    end

    # Logs the status of the execution once it's finished
    def log_finished
      return unless status

      value = status.exitstatus
      return unless value

      message = value.zero? ? "#{GREEN}Done!#{NONE}" : "#{RED}Failed!#{NONE}"

      logger.info("\n#{message}")
    end
  end
end
