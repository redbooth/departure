require 'forwardable'

module Lhm

  # Abstracts the details of a database table column
  class Column
    extend Forwardable

    def_delegators :column, :limit, :type, :default, :null

    # Returns the column's class to be used
    #
    # @return [Constant]
    def self.column_factory
      ::ActiveRecord::ConnectionAdapters::PerconaMigratorAdapter::Column
    end

    # Constructor
    #
    # @param name [String, Symbol]
    # @param definition [String]
    def initialize(name, definition)
      @name = name
      @definition = definition
    end

    # TODO: investigate
    #
    # Rails doesn't take into account lenght argument of INT in the
    # definition, as an integer it will default it to 4 not an integer
    #
    # Returns the columns data as a Hash
    #
    # @return [Hash]
    def to_hash
      { limit: column.limit, default: column.default, null: column.null }
    end

    private

    attr_reader :name, :definition

    # Returns the column instance with the provided data
    #
    # @return [column_factory]
    def column
      @column ||= self.class.column_factory.new(
        name,
        default_value,
        definition,
        null_value
      )
    end

    # Gets the DEFAULT value the column takes as specified in the
    # definition, if any
    #
    # @return [String, NilClass]
    def default_value
      match = if definition =~ /timestamp|datetime/i
                /default '?(.+[^'])'?/i.match(definition)
              else
                /default '?(\w+)'?/i.match(definition)
              end

      return unless match

      match[1].downcase != 'null' ? match[1] : nil
    end

    # Checks whether the column accepts NULL as specified in the definition
    #
    # @return [Boolean]
    def null_value
      match = /((\w*) NULL)/i.match(definition)
      return true unless match

      match[2].downcase == 'not' ? false : true
    end
  end
end
