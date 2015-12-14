class NoStatements < ActiveRecord::Migration
  def up
    Lhm.change_table :comments, { stride: 5000, throttle: 150 } do |c|
    end
  end

  def down
    Lhm.change_table :comments, { stride: 5000, throttle: 150 } do |c|
    end
  end
end
