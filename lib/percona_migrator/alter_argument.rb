module PerconaMigrator

  # Represents the '--alter' argument of Percona's pt-online-schema-change
  # See https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html
  class AlterArgument
    ALTER_TABLE_REGEX = /ALTER TABLE `(\w+)` /

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

    # Returns the name of the table the alter statement refers to
    #
    # @return [String]
    def table_name
      match = statement.match(ALTER_TABLE_REGEX)
      raise StandardError, 'Invalid alter statement' unless match

      match.captures[0]
    end

    private

    attr_reader :statement

    # Removes the 'ALTER TABLE' portion of the SQL statement
    #
    # @return [String]
    def parsed_statement
      @parsed_statement ||= statement
        .gsub(ALTER_TABLE_REGEX, '')
        .gsub('`','\\\`')
    end
  end
end
