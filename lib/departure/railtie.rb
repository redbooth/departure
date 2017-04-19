require 'departure'
require 'lhm' # It's our own Lhm adapter, not the gem
require 'rails'

module Departure
  class Railtie < Rails::Railtie
    railtie_name :departure

    # It drops all previous database connections and reconnects using this
    # PerconaAdapter. By doing this, all later ActiveRecord methods called in
    # the migration will use this adapter instead of Mysql2Adapter.
    #
    # It also patches ActiveRecord's #migrate method so that it patches LHM
    # first. This will make migrations written with LHM to go through the
    # regular Rails Migration DSL.
    initializer 'departure.configure_rails_initialization' do
      ActiveSupport.on_load(:active_record) do
        Departure.load
      end
    end

    initializer 'departure.configure' do |app|
      Departure.configure do |config|
        config.tmp_path = app.paths['tmp'].first
      end
    end
  end
end
