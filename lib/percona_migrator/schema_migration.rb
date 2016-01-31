require 'active_record'

module PerconaMigrator
  # This class is a simplified version of the SchemaMigration model in Rails
  # 4.2. It is meant to have all the logic to handle the ActiveRecord's
  # schema_migrations table. Further details in:
  # https://github.com/rails/rails/blob/19398ab98af04eedb2574890ed0d8ecdf82ebb4c/activerecord/lib/active_record/schema_migration.rb
  class SchemaMigration < ::ActiveRecord::Base
    class << self
      def table_name
        "#{table_name_prefix}#{ActiveRecord::Migrator.schema_migrations_table_name}#{table_name_suffix}"
      end

      def index_name
        "#{table_name_prefix}unique_#{ActiveRecord::Migrator.schema_migrations_table_name}#{table_name_suffix}"
      end

      def table_exists?
        connection.table_exists?(table_name)
      end
    end
  end
end
