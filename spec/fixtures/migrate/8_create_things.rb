class CreateThings < ActiveRecord::Migration
  def up
    create_table :things do |t|
      t.datetime :created_at, null: false
    end
  end

  def down
    drop_table :things
  end
end
