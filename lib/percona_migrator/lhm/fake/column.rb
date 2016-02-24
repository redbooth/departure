require 'forwardable'

module PerconaMigrator
  module Lhm
    module Fake

      class Column
        extend Forwardable

        def_delegators :column, :limit, :type, :default, :null

        def self.column_factory
          ::ActiveRecord::ConnectionAdapters::PerconaMigratorAdapter::Column
        end

        def initialize(name, definition)
          @name = name
          @definition = definition
        end

        # TODO: investigate
        #
        # Rails doesn't take into account lenght argument of INT in the
        # definition, as an integer it will default it to 4 not an integer
        def to_hash
          { limit: column.limit, default: column.default, null: column.null }
        end

        private

        attr_reader :name, :definition

        def column
          @column ||= self.class.column_factory.new(
            name,
            default_value,
            definition,
            null_value
          )
        end

        def default_value
          match = if definition =~ /timestamp|datetime/i
                    /default '?(.+[^'])'?/i.match(definition)
                  else
                    /default '?(\w+)'?/i.match(definition)
                  end

          return unless match

          match[1].downcase != 'null' ? match[1] : nil
        end

        def null_value
          match = /((\w*) NULL)/i.match(definition)
          return true unless match

          match[2].downcase == 'not' ? false : true
        end
      end
    end
  end
end
