module TableMethods
  def columns(table_name)
    ActiveRecord::Base.connection.columns(table_name)
  end

  def unique_indexes_from(table_name)
    indexes = indexes_from(:comments)
    indexes.select(&:unique).map(&:name)
  end

  def indexes_from(table_name)
    ActiveRecord::Base.connection.indexes(:comments)
  end

  def tables
    tables = ActiveRecord::Base.connection.select_all('SHOW TABLES')
    tables.flat_map { |table| table.values }
  end
end
