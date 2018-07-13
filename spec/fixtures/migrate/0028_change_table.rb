class ChangeTable < ActiveRecord::Migration[5.1]
  def change
    change_table :comments do |t|
      t.column :renamable_field, :integer
    end

    change_table :comments do |t|
      t.column :other_boring_id_field, :integer
      t.integer :boring_id_field
      t.timestamps
      t.string :hello

      t.rename(:renamable_field, :renamed_id_field)
    end

    change_table :comments do |t|
      t.change(:hello, :integer)
    end
  end
end
