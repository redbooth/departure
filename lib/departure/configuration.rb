module Departure
  class Configuration
    attr_accessor :tmp_path, :global_percona_args

    def initialize
      @tmp_path = '.'.freeze
      @error_log_filename = 'departure_error.log'.freeze
      @global_percona_args = nil
    end

    def error_log_path
      File.join(tmp_path, error_log_filename)
    end

    private

    attr_reader :error_log_filename
  end
end
