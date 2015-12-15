require 'yaml'

class Configuration
  CONFIG_PATH = 'config.yml'

  attr_reader :config

  def initialize
    @config = YAML.load_file(CONFIG_PATH)
  end

  def [](key)
    config[key]
  end
end
