class ChangeColumnNullFalse < ActiveRecord::Migration
  def change
    change_column_null(:comments, :some_id_field, false)
  end
end
