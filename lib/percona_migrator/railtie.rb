require 'percona_migrator'
require 'rails'

module PerconaMigrator
  class Railtie < Rails::Railtie
    railtie_name :percona_migrator

    # Patches ActiveRecord's #migrate method so that it patches LHM first. This
    # will make migrations written with LHM to go through the regular Rails
    # Migration DSL
    initializer 'percona_migrator.configure_rails_initialization' do
      ActiveRecord::Migration.class_eval do
        alias_method :original_migrate, :migrate
        def migrate(direction)
          PerconaMigrator::Lhm::Fake.patching_lhm(self) do
            original_migrate(direction)
          end
        end
      end
    end

  end
end
