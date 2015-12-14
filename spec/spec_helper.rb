$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'percona_migrator'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  host:     'localhost',
  username: 'root',
  database: 'percona_migrator_test'
)
