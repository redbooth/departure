require 'spec_helper'

describe PerconaMigrator, integration: true do
  class Comment < ActiveRecord::Base; end

  let(:migration_fixtures) do
    ActiveRecord::Migrator.migrations(MIGRATION_FIXTURES)
  end
  let(:migration_path) { [MIGRATION_FIXTURES] }

  let(:direction) { :up }

  context 'managing indexes' do
    let(:version) { 2 }

    context 'adding indexes' do
      let(:direction) { :up }

      # TODO: Create it directly like this?
      before do
        ActiveRecord::Migrator.new(
          direction,
          migration_fixtures,
          1
        ).migrate
      end

      it 'executes the percona command' do
        ActiveRecord::Migrator.new(
          direction,
          migration_fixtures,
          version
        ).migrate

        expect(:comments).to have_index('index_comments_on_some_id_field')
      end

      it 'marks the migration as up' do
        ActiveRecord::Migrator.new(
          direction,
          migration_fixtures,
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
          migration_fixtures,
          1
        ).migrate

        ActiveRecord::Migrator.new(
          :up,
          migration_fixtures,
          version
        ).migrate
      end

      it 'executes the percona command' do
        ActiveRecord::Migrator.new(
          direction,
          migration_fixtures,
          version - 1
        ).migrate

        expect(:comments).not_to have_index('index_comments_on_some_id_field')
      end

      it 'marks the migration as down' do
        ActiveRecord::Migrator.new(
          direction,
          migration_fixtures,
          version - 1
        ).migrate

        expect(ActiveRecord::Migrator.current_version).to eq(1)
      end
    end

    context 'renaming indexes' do
      let(:direction) { :up }
      let(:version) { 13 }

      before do
        ActiveRecord::Migrator.new(:up, migration_fixtures, 2).migrate
      end

      it 'executes the percona command' do
        ActiveRecord::Migrator.run(direction, migration_path, version)
        expect(:comments).to have_index('new_index_comments_on_some_id_field')
      end

      it 'marks the migration as down' do
        ActiveRecord::Migrator.run(direction, migration_path, version)
        expect(ActiveRecord::Migrator.current_version).to eq(version)
      end
    end
  end

  context 'adding/removing unique indexes' do
    let(:version) { 3 }

    context 'adding indexes' do
      let(:direction) { :up }

      before do
        ActiveRecord::Migrator.new(:up, migration_fixtures, 1).migrate
      end

      it 'executes the percona command' do
        ActiveRecord::Migrator.run(direction, migration_path, version)

        expect(unique_indexes_from(:comments))
          .to match_array(['index_comments_on_some_id_field'])
      end

      it 'marks the migration as up' do
        ActiveRecord::Migrator.run(direction, migration_path, version)
        expect(ActiveRecord::Migrator.current_version).to eq(version)
      end
    end

    context 'removing indexes' do
      let(:direction) { :down }

      before do
        ActiveRecord::Migrator.run(:up, migration_path, 1)
        ActiveRecord::Migrator.run(:up, migration_path, version)
      end

      it 'executes the percona command' do
        ActiveRecord::Migrator.run(direction, migration_path, version)

        expect(unique_indexes_from(:comments))
          .not_to match_array(['index_comments_on_some_id_field'])
      end

      it 'marks the migration as down' do
        ActiveRecord::Migrator.run(direction, migration_path, version)
        expect(ActiveRecord::Migrator.current_version).to eq(1)
      end
    end
  end
end
