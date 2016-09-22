class RemoveTimestampOnComments < ActiveRecord::Migration
  def change
    remove_timestamps :comments
  end
end
