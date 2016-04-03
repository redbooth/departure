require 'spec_helper'

# TODO: Handle #change_table syntax
describe PerconaMigrator, integration: true do
  class Comment < ActiveRecord::Base; end

  let(:migration_fixtures) { MIGRATION_FIXTURES }

  def indexes_from(table_name)
    ActiveRecord::Base.connection.indexes(:comments)
  end

  def unique_indexes_from(table_name)
    indexes = indexes_from(:comments)
    indexes.select(&:unique).map(&:name)
  end

  def tables
    tables = ActiveRecord::Base.connection.select_all('SHOW TABLES')
    tables.flat_map { |table| table.values }
  end

  let(:direction) { :up }

  before { ActiveRecord::Migration.verbose = false }

  it 'has a version number' do
    expect(PerconaMigrator::VERSION).not_to be nil
  end

  context 'when ActiveRecord is loaded' do
    it 'reconnects to the database using PerconaAdapter' do
      ActiveRecord::Migrator.new(direction, [migration_fixtures], 1).migrate
      expect(ActiveRecord::Base.connection_pool.spec.config[:adapter]).to eq('percona')
    end

    # TODO: Use dummy app so that we actually go through the railtie's code
    context 'when there is LHM' do
      xit 'patches it to use regular Rails migration methods' do
        expect(PerconaMigrator::Lhm::Fake::Adapter).to receive(:new).and_return(true)
        ActiveRecord::Migrator.new(direction, [migration_fixtures], 1).migrate
      end
    end

    context 'when there is no LHM' do
      xit 'does not patch it' do
        expect(PerconaMigrator::Lhm::Fake).not_to receive(:patching_lhm)
        ActiveRecord::Migrator.new(direction, [migration_fixtures], 1).migrate
      end
    end
  end

  context 'creating/removing columns' do
    let(:version) { 1 }

    context 'creating column' do
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

    context 'droping column' do
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

  context 'adding/removing indexes' do
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

  context 'adding/removing unique indexes' do
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
        ActiveRecord::Migrator.run(:up, [migration_fixtures], 1)
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

  context 'creating a table' do
    let(:version) { 8 }

    it 'creates the table' do
      ActiveRecord::Migrator.run(direction, [migration_fixtures], version)
      expect(tables).to include('things')
    end

    it 'marks the migration as up' do
      ActiveRecord::Migrator.run(direction, [migration_fixtures], version)
      expect(ActiveRecord::Migrator.current_version).to eq(version)
    end
  end

  context 'dropping a table' do
    let(:version) { 8 }
    let(:direction) { :down }

    it 'drops the table' do
      ActiveRecord::Migrator.run(direction, [migration_fixtures], version)
      expect(tables).not_to include('things')
    end

    it 'updates the schema_migrations' do
      ActiveRecord::Migrator.run(direction, [migration_fixtures], version)
      expect(ActiveRecord::Migrator.current_version).to eq(0)
    end
  end

  context 'when the migration failed' do
    context 'and the migration is not an alter table statement' do
      let(:version) { 8 }

      before { ActiveRecord::Base.connection.create_table(:things) }

      it 'raises and halts the execution' do
        expect {
          ActiveRecord::Migrator.run(direction, [migration_fixtures], version)
        }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    context 'and the migration is an alter table statement' do
      let(:version) { 1 }

      before do
        ActiveRecord::Base.connection.add_column(
          :comments,
          :some_id_field,
          :integer
        )
      end

      it 'raises and halts the execution' do
        expect {
          ActiveRecord::Migrator.run(direction, [migration_fixtures], version)
        }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end

  context 'when pt-online-schema-change is not installed' do
    let(:version) { 1 }

    around do |example|
      original_path = ENV['PATH']
      ENV['PATH'] = ''
      example.run
      ENV['PATH'] = original_path
    end

    it 'raises and halts the execution' do
      expect {
        ActiveRecord::Migrator.run(direction, [migration_fixtures], version)
      }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end
