require 'spec_helper'

describe PerconaMigrator, integration: true do
  class Comment < ActiveRecord::Base; end

  let(:migration_fixtures) { MIGRATION_FIXTURES }

  context 'running a migration with #where' do
    let(:version) { 9 }
    let(:direction) { :up }

    before do
      ActiveRecord::Base.connection.add_column(
        :comments,
        :read,
        :boolean,
        default: false,
        null: false
      )

      Comment.create(read: false)
      Comment.create(read: false)
    end

    it 'marks the migration as up' do
      ActiveRecord::Migrator.run(
        direction,
        [migration_fixtures],
        version
      )

      expect(ActiveRecord::Migrator.current_version).to eq(version)
    end

    it 'updates all the required data' do
      ActiveRecord::Migrator.run(
        direction,
        [migration_fixtures],
        version
      )

      expect(Comment.pluck(:read)).to match_array([true, true])
    end
  end
end
