class TestDatabase
  def initialize(config)
    @config = config
  end

  def create
    create_test_database
    create_schema_migrations_table
  end

  private

  attr_reader :config

  def create_test_database
    %x(#{mysql_command} "DROP DATABASE IF EXISTS percona_migrator_test; CREATE DATABASE percona_migrator_test DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci")
    %x(#{mysql_command} "USE percona_migrator_test; DROP TABLE IF EXISTS percona_migrator_test; CREATE TABLE comments (id int(12) NOT NULL AUTO_INCREMENT, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;")
  end

  def create_schema_migrations_table
    PerconaMigrator::SchemaMigration.create_table
  end

  def mysql_command
    "mysql --user=#{config['username']} --password=#{config['password']} -e"
  end
end
