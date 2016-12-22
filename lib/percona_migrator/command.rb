module PerconaMigrator
  # Executes the given command returning it's status and errors
  class Command

    # Constructor
    #
    # @param command [String]
    # @param config [#error_log_path]
    # @param logger [#write_no_newline]
    def initialize(command, config, logger)
      @command = command
      @config = config
      @logger = logger
    end

    # Executes the command returning its status. It also prints its stdout to
    # the logger and its stderr to the file specified in error_log_path
    #
    # @return [Process::Status]
    def run
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
      @status
    end

    private

    attr_reader :command, :config, :logger

    # The path where the percona toolkit stderr will be written
    #
    # @return [String]
    def error_log_path
      config.error_log_path
    end
  end
end
