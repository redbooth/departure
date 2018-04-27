module Departure
  class ConnectionBase < ActiveRecord::Base
    def self.establish_connection(config = nil)
      super
      ActiveRecord::Base.connection_specification_name = connection_specification_name
    end
  end
end
