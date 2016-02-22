module PerconaMigrator
  class AlterArgument

    def initialize(statement)
      @statement = statement
    end

    def to_s
      "--alter \"#{parsed_statement}\""
    end

    private

    attr_reader :statement

    def parsed_statement
      @parsed_statement ||= statement
        .gsub(/ALTER TABLE `(\w+)` /, '')
        .gsub('`','\\\`')
    end
  end
end
