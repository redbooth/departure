$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require './configuration'
require 'percona_migrator'

config = Configuration.new

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  host: 'localhost',
  username: config['username'],
  password: config['password'],
  database: 'percona_migrator_test'
)

MIGRATION_FIXTURES = File.expand_path('../fixtures/migrate/', __FILE__)

RSpec.configure do |config|
  config.before(:all) do
    @initial_migration_paths = ActiveRecord::Migrator.migrations_paths
    ActiveRecord::Migrator.migrations_paths = [MIGRATION_FIXTURES]
  end

  config.before(:each) do
    allow(ActiveRecord::Migrator).to receive(:current_version).and_return(0)
  end

  config.after(:all) do
    ActiveRecord::Migrator.migrations_paths = @initial_migration_paths
  end
end
