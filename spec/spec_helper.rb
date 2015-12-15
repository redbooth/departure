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
