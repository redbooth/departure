module PerconaMigrator
  class Configuration
    attr_accessor :tmp_path

    def initialize
      @tmp_path = 'percona_migrator_error.log'.freeze
    end
  end
end
