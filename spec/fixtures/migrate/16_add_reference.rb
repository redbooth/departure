class AddReference < ActiveRecord::Migration
  def change
    add_reference(:comments, :user)
  end
end
