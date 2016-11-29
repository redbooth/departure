# Defines a matcher to check whether a table contains a given index.
#
# @example Check the comments table contains the index index_comments_on_user_id
#
#   expect(:comments).to have_index('index_comments_on_user_id')
RSpec::Matchers.define :have_index do |expected|
  match do |actual|
    expect(index_names(actual)).to include(expected)
  end

  def index_names(table_name)
    indexes_from(table_name).map(&:name)
  end

  def indexes_from(table_name)
    ActiveRecord::Base.connection.indexes(table_name)
  end
end
