require 'percona_migrator/lhm/fake/adapter'

module PerconaMigrator
  module Lhm
    module Fake

      # Monkeypatches Lhm in the specified migration to return an instance of
      # Adapter. This makes the migratio to go through regular ActiveRecord
      #
      # @param migration [ActiveRecord::Migtration]
      def self.patch_lhm(migration)
        ::Lhm.module_eval do
          @migration = migration

          # Yields an adapter instance so that Lhm migration Dsl methods get
          # delegated to ActiveRecord::Migration ones instead of executing
          #
          # @param table_name [String]
          # @param _options [Hash]
          # @param block [Block]
          def change_table(table_name, _options = {}, &block)
            yield Adapter.new(@migration, table_name)
          end
          alias orig_change_table change_table
        end
      end

      # Undoes the monkeypatch to LHM
      def self.unpatch_lhm
        ::Lhm.module_eval do
          alias change_table orig_change_table
          remove_method(:orig_change_table)
        end
      end

      # Monkeypatches Lhm like in .patch_lhm, yields and then undoes the
      # monkeypatch
      #
      # @param migration [ActiveRecord::Migtration]
      def self.patching_lhm(migration)
        PerconaMigrator::Lhm::Fake.patch_lhm(migration)
        yield
        PerconaMigrator::Lhm::Fake.unpatch_lhm
      end
    end
  end
end
