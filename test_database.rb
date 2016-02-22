class TestDatabase
  def initialize(config)
    @config = config
  end

  # Creates the percona_migrator_test database and comments table in it
  def create_test_database
    %x(#{mysql_command} "DROP DATABASE IF EXISTS percona_migrator_test; CREATE DATABASE percona_migrator_test DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci")
    %x(#{mysql_command} "USE percona_migrator_test; DROP TABLE IF EXISTS comments; CREATE TABLE comments (id int(12) NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;")
  end

  # Creates the ActiveRecord's schema_migrations table required for
  # migrations to work
  def create_schema_migrations_table
    %x(#{mysql_command} "USE percona_migrator_test; DROP TABLE IF EXISTS schema_migrations; CREATE TABLE schema_migrations ( version varchar(255) COLLATE utf8_unicode_ci NOT NULL, UNIQUE KEY unique_schema_migrations (version)) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci")
  end

  private

  attr_reader :config

  def mysql_command
    "mysql --user=#{config['username']} --password=#{config['password']} -e"
  end
end
