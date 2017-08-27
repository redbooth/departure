module Departure
  class InvalidAlterStatement < StandardError; end

  # Represents the '--alter' argument of Percona's pt-online-schema-change
  # See https://www.percona.com/doc/percona-toolkit/2.0/pt-online-schema-change.html
  class AlterArgument
    ALTER_TABLE_REGEX = /\AALTER TABLE `(\w+)` /

    attr_reader :table_name

    # Constructor
    #
    # @param statement [String]
    # @raise [InvalidAlterStatement] if the statement is not an ALTER TABLE
    def initialize(statement)
      @statement = statement

      match = statement.match(ALTER_TABLE_REGEX)
      raise InvalidAlterStatement unless match

      @table_name = match.captures[0]
    end

    # Returns the '--alter' pt-online-schema-change argument as a string. See
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
        .gsub(ALTER_TABLE_REGEX, '')
        .gsub('`', '\\\`')
    end
  end
end
