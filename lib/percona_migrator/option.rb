module PerconaMigrator
  class Option
    attr_reader :name, :value

    # Builds an instance by parsing its name and value out of the given string.
    # Note the string must be conform to "--<arg>=<value>" format.
    #
    # @param string [String]
    # @return [Option]
    def self.from_string(string)
      pair = string.split('=')
      name = pair[0][2..-1]
      value = pair[1]

      new(name, value)
    end

    # Constructor
    #
    # @param name [String]
    # @param optional value [String]
    def initialize(name, value = nil)
      @name = name
      @value = value
    end

    # Compares two options
    #
    # @param [Option]
    # @return [Boolean]
    def ==(another_option)
      name == another_option.name
    end
    alias :eql? :==

    # Returns the option's hash
    #
    # @return [Fixnum]
    def hash
      name.hash
    end

    # Returns the option as string following the "--<name>=<value>" format
    #
    # @return [String]
    def to_s
      "--#{name}#{value_as_string}"
    end

    private

    # Returns the value fragment of the option string if any value is specified
    #
    # @return [String]
    def value_as_string
      if value.nil?
        ''
      else
        "=#{value}"
      end
    end
  end
end
