require 'spec_helper'

describe Departure, integration: true do
  class Comment < ActiveRecord::Base; end

  let(:migration_fixtures) do
    ActiveRecord::Migrator.migrations(MIGRATION_FIXTURES)
  end
  let(:migration_path) { [MIGRATION_FIXTURES] }

  let(:direction) { :up }

  context 'adding foreign keys' do
    let(:version) { 26 }

    before do
      ActiveRecord::Base.connection.create_table(:products)

      ActiveRecord::Base.connection.add_column(
        :comments,
        :product_id,
        :bigint
      )
    end

    it 'adds a foreign key' do
      ActiveRecord::Migrator.run(direction, migration_path, version)
      expect(:comments).to have_foreign_key_on('product_id')
    end
  end

  context 'removing foreign keys' do
    let(:version) { 27 }

     before do
       ActiveRecord::Base.connection.create_table(:products)

       ActiveRecord::Base.connection.add_column(
          :comments,
          :product_id,
          :bigint
       )

      ActiveRecord::Base.connection.add_foreign_key(
        :comments,
        :products
      )
    end

   it 'removes a foreign key' do
      ActiveRecord::Migrator.run(direction, migration_path, version)
      expect(:comments).not_to have_foreign_key_on('product_id')
    end
  end
end
