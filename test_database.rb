# Setups the test database with the schema_migrations table that ActiveRecord
# requires for the migrations, plus a table for the Comment model used throught
# the tests.
#
class TestDatabase

  # Constructor
  #
  # @param config [Hash]
  def initialize(config)
    @config = config
    @database = config['database']
  end

  # Creates the test database, the schema_migrations and the comments tables.
  # It drops any of them if they already exist
  def setup
    setup_test_database
    drop_and_create_schema_migrations_table
  end

  # Creates the departure_test database and the comments table in it.
  # Before, it drops both if they already exist
  def setup_test_database
    drop_and_create_test_database
    drop_and_create_comments_table
  end

  # Creates the ActiveRecord's schema_migrations table required for
  # migrations to work. Before, it drops the table if it already exists
  def drop_and_create_schema_migrations_table
    %x(#{mysql_command} "USE #{database}; DROP TABLE IF EXISTS schema_migrations; CREATE TABLE schema_migrations ( version varchar(255) COLLATE utf8_unicode_ci NOT NULL, UNIQUE KEY unique_schema_migrations (version)) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
  end

  private

  attr_reader :config, :database

  def drop_and_create_test_database
    %x(#{mysql_command} "DROP DATABASE IF EXISTS #{database}; CREATE DATABASE #{database} DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci;")
  end

  def drop_and_create_comments_table
    %x(#{mysql_command} "USE #{database}; DROP TABLE IF EXISTS comments; CREATE TABLE comments ( id int(12) NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;")
  end

  # Returns the command to run the mysql client. It uses the crendentials from
  # the provided config
  def mysql_command
    "mysql --user=#{config['username']} --password=#{config['password']} -e"
  end
end
