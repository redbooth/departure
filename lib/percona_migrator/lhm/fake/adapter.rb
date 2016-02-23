module PerconaMigrator
  module Lhm
    module Fake

      class Adapter
        def initialize(migration, table_name)
          @migration = migration
          @table_name = table_name
        end

        # Translates the Lhm's add_column syntax to ActiveRecord's and calls it
        # in the given migration
        def add_column(column_name, definition)
          type = type_from(column_name, definition)
          options = options_from(column_name, definition)

          migration.add_column(table_name, column_name, type, options)
        end

        private

        attr_reader :migration, :table_name

        def type_from(name, definition)
          column(name, definition).type
        end

        # TODO: investigate
        #
        # Rails doesn't take into account lenght argument of INT in the
        # definition, as an integer it will default it to 4 not an integer
        def options_from(name, definition)
          column = column(name, definition)
          { limit: column.limit, default: column.default }
        end

        def default_value(definition)
          match = /default '(\w+)'/i.match(definition)
          match ? match[1] : nil
        end

        def column(name, definition)
          @column ||= self.class.column_factory.new(
            name,
            default_value(definition),
            definition
          )
        end

        def self.column_factory
          ::ActiveRecord::ConnectionAdapters::PerconaMigratorAdapter::Column
        end
      end
    end
  end
end
