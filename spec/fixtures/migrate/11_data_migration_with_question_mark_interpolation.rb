class DataMigrationWithQuestionMarkInterpolation < ActiveRecord::Migration
  class Comment < ActiveRecord::Base; end

  def up
    unread_comments = Comment.where('`read` = ?', false)
    unread_comments.update_all(read: true)
  end

  def down
  end
end
