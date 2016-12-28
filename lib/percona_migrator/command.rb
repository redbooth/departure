module PerconaMigrator
  # Executes the given command returning it's status and errors
  class Command
    COMMAND_NOT_FOUND = 127

    # Constructor
    #
    # @param command [String]
    # @param error_log_path [String]
    # @param logger [#write_no_newline]
    def initialize(command, error_log_path, logger)
      @command = command
      @error_log_path = error_log_path
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
      validate_status!
      status
    end

    private

    attr_reader :command, :error_log_path, :logger, :status

    # Validates the status of the execution
    #
    # @raise [NoStatusError] if the spawned process' status can't be retrieved
    # @raise [SignalError] if the spawned process received a signal
    # @raise [CommandNotFoundError] if pt-online-schema-change can't be found
    def validate_status!
      raise SignalError.new(status) if status.signaled?
      raise CommandNotFoundError if status.exitstatus == COMMAND_NOT_FOUND
      raise Error, error_message unless status.success?
    end

    # @return [String]
    def error_message
      File.read(error_log_path)
    end
  end
end
