class CreateUniqueIndexOnComments < ActiveRecord::Migration
  def up
    Lhm.change_table :comments, { stride: 5000, throttle: 150 } do |c|
      c.add_unique_index :some_id_field
    end
  end

  def down
    Lhm.change_table :comments, { stride: 5000, throttle: 150 } do |c|
      c.remove_index :some_id_field
    end
  end
end
