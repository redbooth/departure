module PerconaMigrator
  # Holds the parameters of the DB connection and formats them to string
  class ConnectionDetails

    # Constructor
    #
    # @param [Hash] connection parametes as used in #establish_conneciton
    def initialize(connection_data)
      @connection_data = connection_data
    end

    # Returns the details formatted as an string to be used with
    # pt-online-schema-change. It follows the mysql client's format.
    #
    # @return [String]
    def to_s
      @to_s ||= "-h #{host} -u #{user} #{password_argument}"
    end

    # TODO: Doesn't the abstract adapter already handle this somehow?
    # Returns the database name. If PERCONA_DB_NAME is passed its value will be
    # used instead
    #
    # Returns the database name
    #
    # @return [String]
    def database
      ENV.fetch('PERCONA_DB_NAME', connection_data[:database])
    end

    # Returns the password fragment of the details string if a password is passed
    #
    # @return [String]
    def password_argument
      if password.present?
        "-p #{password}"
      else
        ''
      end
    end

    # Returns the database host name, defaulting to localhost. If PERCONA_DB_HOST
    # is passed its value will be used instead
    #
    # @return [String]
    def host
      ENV.fetch('PERCONA_DB_HOST', connection_data[:host]) || 'localhost'
    end

    # Returns the database user. If PERCONA_DB_USER is passed its value will be
    # used instead
    #
    # @return [String]
    def user
      ENV.fetch('PERCONA_DB_USER', connection_data[:username])
    end

    # Returns the database user's password. If PERCONA_DB_PASSWORD is passed its
    # value will be used instead
    #
    # @return [String]
    def password
      ENV.fetch('PERCONA_DB_PASSWORD', connection_data[:password])
    end

    private

    attr_reader :connection_data
  end
end
