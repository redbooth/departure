module Lhm
  # Abstracts the details of a table column definition when specified with a type
  # as a symbol. This is the regular ActiveRecord's #add_column syntax:
  #
  #   add_column :tablenames, :field, :string
  #
  class ColumnWithType
    # Constructor
    #
    # @param name [String, Symbol]
    # @param definition [Symbol]
    def initialize(name, definition)
      @name = name
      @definition = definition
    end

    # Returns the column data as an Array to be used with the splat operator.
    # See Lhm::Adaper#add_column
    #
    # @return [Array]
    def attributes
      [definition]
    end

    private

    attr_reader :definition
  end
end
