require 'percona_migrator'
require 'rails'

module PerconaMigrator
  class Railtie < Rails::Railtie
    railtie_name :percona_migrator

    # It drops all previous database connections and reconnects using this
    # PerconaAdapter. By doing this, all later ActiveRecord methods called in
    # the migration will use this adapter instead of Mysql2Adapter.
    #
    # It also patches ActiveRecord's #migrate method so that it patches LHM
    # first. This will make migrations written with LHM to go through the
    # regular Rails Migration DSL.
    initializer 'percona_migrator.configure_rails_initialization' do
      ActiveSupport.on_load(:active_record) do
        require 'percona_migrator/lhm/fake'

        ActiveRecord::Migration.class_eval do
          alias_method :original_migrate, :migrate

          # Replaces the current connection adapter with the PerconaAdapter and
          # patches LHM, then it continues with the regular migration process.
          #
          # @param direction [Symbol] :up or :down
          def migrate(direction)
            reconnect_with_percona

            PerconaMigrator::Lhm::Fake.patching_lhm(self) do
              original_migrate(direction)
            end
          end

          # Make all connections in the connection pool to use PerconaAdapter
          # instead of the current adapter.
          def reconnect_with_percona
            connection_config = ActiveRecord::Base.connection_config
            ActiveRecord::Base.establish_connection(
              connection_config.merge(adapter: 'percona')
            )
          end
        end
      end
    end
  end
end
