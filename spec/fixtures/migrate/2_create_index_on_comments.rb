class CreateIndexOnComments < ActiveRecord::Migration
  def change
    add_index :comments, :some_id_field
  end
end
