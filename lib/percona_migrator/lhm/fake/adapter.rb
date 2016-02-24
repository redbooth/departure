require 'percona_migrator/lhm/fake/column'

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
          column = column(column_name, definition)

          migration.add_column(
            table_name,
            column_name,
            column.type,
            column.to_hash
          )
        end

        def remove_column(column_name)
          migration.remove_column(table_name, column_name)
        end

        def add_index(columns, index_name = nil)
          options = { name: index_name } if index_name
          migration.add_index(table_name, columns, options || {})
        end

        def remove_index(columns, index_name = nil)
          options = if index_name
                      { name: index_name }
                    else
                      { column: columns }
                    end
          migration.remove_index(table_name, options)
        end

        def change_column(column_name, definition)
          column = column(column_name, definition)

          migration.change_column(
            table_name,
            column_name,
            column.type,
            column.to_hash
          )
        end

        def rename_column(old_name, new_name)
          migration.rename_column(table_name, old_name, new_name)
        end

        def add_unique_index(columns, index_name = nil)
          options = { unique: true }
          options.merge!(name: index_name) if index_name

          migration.add_index(table_name, columns, options)
        end

        private

        attr_reader :migration, :table_name

        def column(name, definition)
          @column ||= Column.new(name, definition)
        end
      end
    end
  end
end
