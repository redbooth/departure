require 'active_record'
require 'active_support/all'

require 'percona_migrator/version'
require 'percona_migrator/log_sanitizers/connection_details_sanitizer'
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
    ActiveRecord::Migrator.instance_eval do
      class << self
        alias_method(:original_migrate, :migrate)
      end

      # Checks whether arguments are being passed through PERCONA_ARGS when running
      # the db:migrate rake task
      #
      # @raise [ArgumentsNotSupported] if PERCONA_ARGS has any value
      def migrate(migrations_paths, target_version = nil, &block)
        raise ArgumentsNotSupported if ENV['PERCONA_ARGS'].present?
        original_migrate(migrations_paths, target_version, &block)
      end
    end

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
        connection_config = ActiveRecord::Base
          .connection_config.merge(adapter: 'percona')
        ActiveRecord::Base.establish_connection(connection_config)
      end
    end
  end
end
