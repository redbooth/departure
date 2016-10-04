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
end
