require 'percona_migrator/lhm/fake/adapter'

module PerconaMigrator
  module Lhm
    module Fake

      # Monkeypatch LHM not to run a migration, but return the parsed statements
      # Refinements will not work here because LHM is a module and it can't be
      # refined
      def self.patch_lhm(migration)
        ::Lhm.module_eval do
          @migration = migration

          # Yields an adapter instance so that Lhm migration Dsl methods get
          # passed to ActiveRecord upon translation instead of executing the
          # migration through Lhm
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

      def self.patching_lhm(migration)
        PerconaMigrator::Lhm::Fake.patch_lhm(migration)
        yield
        PerconaMigrator::Lhm::Fake.unpatch_lhm
      end
    end
  end
end
