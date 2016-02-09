require 'open3'

module PerconaMigrator
  class Runner

    NONE = "\e[0m"
    CYAN = "\e[38;5;86m"
    GREEN = "\e[32m"
    RED = "\e[31m"

    def self.execute(command, logger)
      new(command, logger).execute
    end

    def initialize(command, logger)
      @command = command
      @logger = logger
      @status = nil
    end

    # Runs and logs the given command
    #
    # @return [Boolean]
    def execute
      log_started
      run_command
      log_finished

      status
    end

    private

    attr_reader :command, :logger, :status

    def log_started
      # TODO: log as a migration logger subitem
      logger.puts "\n#{CYAN}-- #{command}#{NONE}\n\n"
    end

    def run_command
      Open3.popen2(command) do |_stdin, stdout, process|
        @status = process.value
        logger.puts stdout.read
      end
    end

    def log_finished
      logger.puts(status ? "\n#{GREEN}Done!#{NONE}" : "\n#{RED}Failed!#{NONE}")
    end
  end
end
