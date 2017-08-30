module Departure
  module LoggerFactory
    # Returns the appropriate logger instance for the given configuration. Use
    # :verbose option to log to the stdout
    #
    # @param verbose [Boolean]
    # @return [#say, #write]
    def self.build(sanitizers: [], verbose: true)
      if verbose
        Departure::Logger.new(sanitizers)
      else
        Departure::NullLogger.new
      end
    end
  end
end
