require 'percona_migrator'
require 'rails'

module PerconaMigrator
  class Railtie < Rails::Railtie
    railtie_name :percona_migrator

    rake_tasks do
      load 'percona_migrator/percona_migrator.rake'
    end
  end
end
