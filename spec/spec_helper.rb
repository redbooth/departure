$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require './configuration'
require './test_database'
require 'percona_migrator'

db_config = Configuration.new

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
  config.order = 'random'

  config.before(:all) do
    test_database.create_schema_migrations_table

    @initial_migration_paths = ActiveRecord::Migrator.migrations_paths
    ActiveRecord::Migrator.migrations_paths = [MIGRATION_FIXTURES]
  end

  config.after(:all) do
    ActiveRecord::Migrator.migrations_paths = @initial_migration_paths
  end

  # Cleans up the database after each example ala Database Cleaner
  config.around(:each) do |example|
    example.run

    if example.metadata[:integration]
      test_database.create_test_database
    end
  end
end
