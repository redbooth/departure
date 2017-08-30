# Defines a matcher to check whether a table contains a given column.
#
# @example Check the comments table contains the id column:
#
#   expect(:comments).to have_column('id')
RSpec::Matchers.define :have_column do |expected|
  match do |actual|
    expect(column_names(actual)).to include(expected)
  end

  def column_names(table_name)
    columns(table_name).map(&:name)
  end

  def columns(table_name)
    ActiveRecord::Base.connection.columns(table_name)
  end
end
