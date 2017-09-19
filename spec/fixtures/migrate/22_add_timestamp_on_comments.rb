class AddTimestampOnComments < ActiveRecord::Migration[5.0]
  def change
    add_timestamps :comments, null: true, default: nil
  end
end
