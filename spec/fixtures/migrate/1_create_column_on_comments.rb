class CreateColumnOnComments < ActiveRecord::Migration
  def change
    add_column(
      :comments,
      :some_id_field,
      :integer,
      { limit: 11, default: nil }
    )
  end
end
