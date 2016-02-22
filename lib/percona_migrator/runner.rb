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

    def initialize(logger)
      @logger = logger
      @status = nil
    end

    # Runs and logs the given command
    #
    # @return [Boolean]
    def execute(command)
      @command = command

      log_started
      run_command
      log_finished

      status
    end

    private

    attr_reader :command, :logger, :status

    # TODO: log as a migration logger subitem
    def log_started
      logger.puts "\n#{CYAN}-- #{command}#{NONE}\n\n"
    end

    def run_command
      Open3.popen2(command) do |_stdin, stdout, process|
        @status = process.value
        logger.puts stdout.read
      end

      if status.nil?
        Kernel.warn("Error running '#{command}': status could not be retrieved")
      end

      if status && status.signaled?
        Kernel.warn("Error running '#{command}': #{status.to_s}")
      end
    end

    def log_finished
      return unless status

      value = status.exitstatus
      return unless value

      message = value.zero? ? "#{GREEN}Done!#{NONE}" : "#{RED}Failed!#{NONE}"

      logger.puts("\n#{message}")
    end
  end
end
