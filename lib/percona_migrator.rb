require 'active_record'
require 'active_support/all'

require 'percona_migrator/version'
require 'percona_migrator/runner'
require 'percona_migrator/cli_generator'
require 'percona_migrator/logger'
require 'percona_migrator/null_logger'
require 'percona_migrator/logger_factory'
require 'percona_migrator/configuration'
require 'percona_migrator/errors'
require 'percona_migrator/command'

require 'percona_migrator/railtie' if defined?(Rails)

# We need the OS not to buffer the IO to see pt-osc's output while migrating
$stdout.sync = true

module PerconaMigrator
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  # Hooks Percona Migrator into Rails migrations by replacing the configured
  # database adapter
  def self.load
    ActiveRecord::Migration.class_eval do
      alias_method :original_migrate, :migrate

      # Replaces the current connection adapter with the PerconaAdapter and
      # patches LHM, then it continues with the regular migration process.
      #
      # @param direction [Symbol] :up or :down
      def migrate(direction)
        reconnect_with_percona
        include_foreigner if defined?(Foreigner)

        ::Lhm.migration = self
        original_migrate(direction)
      end

      # Includes the Foreigner's Mysql2Adapter implemention in
      # PerconaMigratorAdapter to support foreign keys
      def include_foreigner
        Foreigner::Adapter.safe_include(
          :PerconaMigratorAdapter,
          Foreigner::ConnectionAdapters::Mysql2Adapter
        )
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
