module PerconaMigrator

  # Represents the '--alter' argument of Percona's pt-online-schema-change
  # See https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html
  class AlterArgument

    # Constructor
    #
    # @param statement [String]
    def initialize(statement)
      @statement = statement
    end

    # Returns the '--alter' pt-online-schema-change argumment as a string. See
    # https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html
    def to_s
      "--alter \"#{parsed_statement}\""
    end

    private

    attr_reader :statement

    # Removes the 'ALTER TABLE' portion of the SQL statement
    #
    # @return [String]
    def parsed_statement
      @parsed_statement ||= statement
        .gsub(/ALTER TABLE `(\w+)` /, '')
        .gsub('`','\\\`')
    end
  end
end
