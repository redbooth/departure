class AddPolymorphicReferenceWithIndex < ActiveRecord::Migration
  def change
    add_reference(:comments, :user, polymorphic: true, index: true)
  end
end
