$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require './configuration'
require './test_database'
require 'percona_migrator'

db_config = Configuration.new

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: 'localhost',
  username: db_config['username'],
  password: db_config['password'],
  database: 'percona_migrator_test'
)

MIGRATION_FIXTURES = File.expand_path('../fixtures/migrate/', __FILE__)

RSpec.configure do |config|
  config.order = 'random'

  config.before(:all) do
    @initial_migration_paths = ActiveRecord::Migrator.migrations_paths
    ActiveRecord::Migrator.migrations_paths = [MIGRATION_FIXTURES]
  end

  config.after(:all) do
    ActiveRecord::Migrator.migrations_paths = @initial_migration_paths
  end

  # Cleans up the database after each example ala Database Cleaner
  config.around(:each) do |example|
    example.run
    TestDatabase.new(db_config).create
  end
end
