module PerconaMigrator
  class Configuration
    attr_accessor :tmp_path

    def initialize
      @tmp_path = '.'.freeze
      @error_log_filename = 'departure_error.log'.freeze
    end

    def error_log_path
      File.join(tmp_path, error_log_filename)
    end

    private

    attr_reader :error_log_filename
  end
end
