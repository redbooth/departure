class RenameCommentsToNewComments < ActiveRecord::Migration
  def change
    rename_table :comments, :new_comments
  end
end
