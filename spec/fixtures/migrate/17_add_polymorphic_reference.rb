class AddPolymorphicReference < ActiveRecord::Migration
  def change
    add_reference(:comments, :user, polymorphic: true)
  end
end
