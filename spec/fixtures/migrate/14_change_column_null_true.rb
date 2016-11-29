class ChangeColumnNullTrue < ActiveRecord::Migration
  def change
    change_column_null(:comments, :some_id_field, true)
  end
end
