class AddTimestampOnComments < ActiveRecord::Migration
  def change
    add_timestamps :comments
  end
end
