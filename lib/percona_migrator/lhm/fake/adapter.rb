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
          type = :integer
          options = { limit: 11, default: nil }

          migration.add_column(table_name, column_name, type, options)
        end

        private

        attr_reader :migration, :table_name
      end
    end
  end
end
