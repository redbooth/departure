require 'active_record'
require 'active_support/all'

require 'percona_migrator/version'
require 'percona_migrator/runner'
require 'percona_migrator/cli_generator'
require 'percona_migrator/logger'

require 'percona_migrator/railtie' if defined?(Rails)

module PerconaMigrator
end
