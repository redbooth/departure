module Lhm
  class SimpleColumn

    # Constructor
    #
    # @param name [String, Symbol]
    # @param definition [Symbol]
    def initialize(name, definition)
      @name = name
      @definition = definition
    end

    def attributes
      [definition]
    end

    private

    attr_reader :definition
  end
end
