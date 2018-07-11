# Defines a matcher to check whether a table contains a foreign key on a given column.
#
# @example Check the comments table contains a foreign key on user_id column:
#
#   expect(:comments).to have_foreign_key('user_id')
RSpec::Matchers.define :have_foreign_key_on do |expected|
  match do |actual|
    expect(foreign_key_column_names(actual)).to include(expected)
  end

  def foreign_key_column_names(table_name)
    foreign_keys(table_name).map { |fk| fk.options[:column] }
  end

  def foreign_keys(table_name)
    ActiveRecord::Base.connection.foreign_keys(table_name)
  end
end
