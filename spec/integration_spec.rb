require 'spec_helper'

# TODO: Handle #change_table syntax
describe PerconaMigrator do
  class Comment < ActiveRecord::Base; end

  let(:migration_fixtures) { MIGRATION_FIXTURES }

  def indexes_from(table_name)
    ActiveRecord::Base.connection.indexes(:comments)
  end

  def unique_indexes_from(table_name)
    indexes = indexes_from(:comments)
    indexes.select(&:unique).map(&:name)
  end

  let(:direction) { :up }
  # TODO: use this logger
  let(:logger) { double(:logger, puts: true) }

  before { ActiveRecord::Migration.verbose = false }

  it 'has a version number' do
    expect(PerconaMigrator::VERSION).not_to be nil
  end

  context 'creating/removing columns' do
    let(:version) { 1 }

    context 'creating column', integration: true do
      let(:direction) { :up }

      it 'adds the column in the DB table' do
        ActiveRecord::Migrator.new(
          direction,
          [migration_fixtures],
          version
        ).migrate

        Comment.reset_column_information
        expect(Comment.column_names).to include('some_id_field')
      end

      it 'marks the migration as up' do
        ActiveRecord::Migrator.new(
          direction,
          [migration_fixtures],
          version
        ).migrate

        expect(ActiveRecord::Migrator.current_version).to eq(version)
      end
    end

    context 'droping column', integration: true do
      let(:direction) { :down }

      before do
        ActiveRecord::Migrator.new(
          :up,
          [migration_fixtures],
          version
        ).migrate
      end

      it 'drops the column from the DB table' do
        ActiveRecord::Migrator.new(
          direction,
          [migration_fixtures],
          version - 1
        ).migrate

        Comment.reset_column_information
        expect(Comment.column_names).not_to include('some_id_field')
      end

      it 'marks the migration as down' do
        ActiveRecord::Migrator.new(
          direction,
          [migration_fixtures],
          version - 1
        ).migrate

        expect(ActiveRecord::Migrator.current_version).to eq(version - 1)
      end
    end
  end

  context 'adding/removing indexes', index: true do
    let(:version) { 2 }

    context 'adding indexes' do
      let(:direction) { :up }

      # TODO: Create it directly like this?
      before do
        ActiveRecord::Migrator.new(
          direction,
          [migration_fixtures],
          1
        ).migrate
      end

      it 'executes the percona command' do
        ActiveRecord::Migrator.new(
          direction,
          [migration_fixtures],
          version
        ).migrate

        expect(indexes_from(:comments).map(&:name)).to(
          contain_exactly('index_comments_on_some_id_field')
        )
      end

      it 'marks the migration as up' do
        ActiveRecord::Migrator.new(
          direction,
          [migration_fixtures],
          version
        ).migrate

        expect(ActiveRecord::Migrator.current_version).to eq(version)
      end
    end

    context 'removing indexes' do
      let(:direction) { :down }

      before do
        ActiveRecord::Migrator.new(
          :up,
          [migration_fixtures],
          1
        ).migrate

        ActiveRecord::Migrator.new(
          :up,
          [migration_fixtures],
          version
        ).migrate
      end

      it 'executes the percona command' do
        ActiveRecord::Migrator.new(
          direction,
          [migration_fixtures],
          version - 1
        ).migrate

        expect(indexes_from(:comments).map(&:name)).not_to(
          include('index_comments_on_some_id_field')
        )
      end

      it 'marks the migration as down' do
        ActiveRecord::Migrator.new(
          direction,
          [migration_fixtures],
          version - 1
        ).migrate

        expect(ActiveRecord::Migrator.current_version).to eq(1)
      end
    end
  end

  context 'adding/removing unique indexes', index: true do
    let(:version) { 3 }

    context 'adding indexes' do
      let(:direction) { :up }

      before do
        ActiveRecord::Migrator.new(:up, [migration_fixtures], 1).migrate
      end

      it 'executes the percona command' do
        ActiveRecord::Migrator.run(direction, [migration_fixtures], version)

        expect(unique_indexes_from(:comments)).to(
          match_array(['index_comments_on_some_id_field'])
        )
      end

      it 'marks the migration as up' do
        ActiveRecord::Migrator.run(direction, [migration_fixtures], version)
        expect(ActiveRecord::Migrator.current_version).to eq(version)
      end
    end

    context 'removing indexes' do
      let(:direction) { :down }

      before do
        ActiveRecord::Migrator.new(:up, [migration_fixtures], 1).migrate
        ActiveRecord::Migrator.run(:up, [migration_fixtures], version)
      end

      it 'executes the percona command' do
        ActiveRecord::Migrator.run(direction, [migration_fixtures], version)

        expect(unique_indexes_from(:comments)).not_to(
          match_array(['index_comments_on_some_id_field'])
        )
      end

      it 'marks the migration as down' do
        ActiveRecord::Migrator.run(direction, [migration_fixtures], version)
        expect(ActiveRecord::Migrator.current_version).to eq(1)
      end
    end
  end
end
