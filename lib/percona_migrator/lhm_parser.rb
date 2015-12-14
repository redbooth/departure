module PerconaMigrator
  module LhmParser
    module_function

    # Parses LHM statements into Percona ones.
    # It removes all 'alter `table`' parts and changes `create` into `add`
    # Supports all LHM methods except `filter`
    #
    # @param results [Array] LHM statements
    def parse(statements)
      any_statements?(statements)

      statements.map do |statement|
        case statement
        when is_statement?('alter')
          parse_alter_statement(statement)
        when is_statement?(/^create\s(unique\s)?index/)
          parse_create_index_statement(statement)
        when is_statement?('drop index')
          parse_drop_index_statement(statement)
        else
          raise "don't know how to parse statement #{statement}"
        end
      end
    end

    def any_statements?(statements)
      error_text = 'No statements were parsed. You specified non-LHM migration or maybe due a parser bug'
      raise error_text if statements.empty?
    end

    # checks if passed statement tags with the passed label
    #
    # @param statement [String] implicit, passed to lambda call
    # @param label [String|Regexp]
    # @return Boolean
    def is_statement?(label)
      lambda { |s| label.is_a?(String) ? s.start_with?(label) : s.match(label) }
    end

    def parse_alter_statement(statement)
      statement.gsub(/^alter table `?.*?`?\s/, '')
    end

    def parse_create_index_statement(statement)
      statement.gsub(/\son\s`.*?`/, '').gsub(/^create/, 'add')
    end

    def parse_drop_index_statement(statement)
      statement.gsub(/\son\s`.*?`/, '')
    end
  end
end
