require 'spec_helper'

describe PerconaMigrator, integration: true do
  class Comment < ActiveRecord::Base; end

  let(:migration_fixtures) { MIGRATION_FIXTURES }
  let(:direction) { :up }

  before do
    ActiveRecord::Base.connection.add_column(
      :comments,
      :read,
      :boolean,
      default: false,
      null: false
    )

    Comment.reset_column_information

    Comment.create(read: false)
    Comment.create(read: false)
  end

  context 'running a migration with #update_all' do
    let(:version) { 9 }

    it 'updates all the required data' do
      ActiveRecord::Migrator.run(
        direction,
        [migration_fixtures],
        version
      )

      expect(Comment.pluck(:read)).to match_array([true, true])
    end

    it 'marks the migration as up' do
      ActiveRecord::Migrator.run(
        direction,
        [migration_fixtures],
        version
      )

      expect(ActiveRecord::Migrator.current_version).to eq(version)
    end
  end

  context 'running a migration with #find_each' do
    let(:version) { 10 }

    it 'updates all the required data' do
      ActiveRecord::Migrator.run(
        direction,
        [migration_fixtures],
        version
      )

      expect(Comment.pluck(:read)).to match_array([true, true])
    end

    it 'marks the migration as up' do
      ActiveRecord::Migrator.run(
        direction,
        [migration_fixtures],
        version
      )

      expect(ActiveRecord::Migrator.current_version).to eq(version)
    end
  end

  context 'running a migration with ? interpolation' do
    let(:version) { 11 }

    it 'updates all the required data' do
      ActiveRecord::Migrator.run(
        direction,
        [migration_fixtures],
        version
      )

      expect(Comment.pluck(:read)).to match_array([true, true])
    end

    it 'marks the migration as up' do
      ActiveRecord::Migrator.run(
        direction,
        [migration_fixtures],
        version
      )

      expect(ActiveRecord::Migrator.current_version).to eq(version)
    end
  end

  context 'running a migration with named bind variables' do
    let(:version) { 12 }

    it 'updates all the required data' do
      ActiveRecord::Migrator.run(
        direction,
        [migration_fixtures],
        version
      )

      expect(Comment.pluck(:read)).to match_array([true, true])
    end

    it 'marks the migration as up' do
      ActiveRecord::Migrator.run(
        direction,
        [migration_fixtures],
        version
      )

      expect(ActiveRecord::Migrator.current_version).to eq(version)
    end
  end
end
