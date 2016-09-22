require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

Bundler.require(:default, :development)

require './configuration'
require './test_database'

require 'percona_migrator'
require 'lhm'

require 'support/matchers/have_column'
require 'support/matchers/have_index'

db_config = Configuration.new

# Disables/enables the queries log you see in your rails server in dev mode
fd = ENV['VERBOSE'] ? STDOUT : '/dev/null'
ActiveRecord::Base.logger = Logger.new(fd)

ActiveRecord::Base.establish_connection(
  adapter: 'percona',
  host: 'localhost',
  username: db_config['username'],
  password: db_config['password'],
  database: 'percona_migrator_test'
)

MIGRATION_FIXTURES = File.expand_path('../fixtures/migrate/', __FILE__)

test_database = TestDatabase.new(db_config)

RSpec.configure do |config|
  ActiveRecord::Migration.verbose = false

  # Needs an empty block to initialize the config with the default values
  PerconaMigrator.configure do |config|
  end

  config.around(:each) do |example|

    # Cleans up the database before each example, so the current example doesn't
    # see the state of the previous one
    if example.metadata[:integration]
      test_database.setup
      example.run
    else
      example.run
    end
  end

  config.order = :random

  Kernel.srand config.seed
end

def columns(table_name)
  ActiveRecord::Base.connection.columns(table_name)
end

def unique_indexes_from(table_name)
  indexes = indexes_from(:comments)
  indexes.select(&:unique).map(&:name)
end

def indexes_from(table_name)
  ActiveRecord::Base.connection.indexes(:comments)
end

def tables
  tables = ActiveRecord::Base.connection.select_all('SHOW TABLES')
  tables.flat_map { |table| table.values }
end
