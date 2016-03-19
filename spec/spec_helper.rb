$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

Bundler.require(:default, :development)

require './configuration'
require './test_database'

require 'percona_migrator'
require 'lhm'

db_config = Configuration.new

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
