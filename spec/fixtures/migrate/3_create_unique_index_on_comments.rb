class CreateUniqueIndexOnComments < ActiveRecord::Migration
  def change
    add_index :comments, :some_id_field, unique: true
  end
end
