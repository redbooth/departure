module PerconaMigrator
  module LogSanitizers
    class ConnectionDetailsSanitizer

      delegate :password_argument, to: :connection_details

      def initialize(connection_details)
        @connection_details = connection_details
      end

      def execute(log_statement)
        password_argument.blank? ? log_statement : log_statement.gsub(connection_details.password_argument, '[filtered_password]')
      end

      private
      attr_accessor :connection_details
    end
  end
end