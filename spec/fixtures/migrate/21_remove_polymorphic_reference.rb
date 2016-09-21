class RemovePolymorphicReference < ActiveRecord::Migration
  def change
    remove_reference :comments, :user, polymorphic: true
  end
end
