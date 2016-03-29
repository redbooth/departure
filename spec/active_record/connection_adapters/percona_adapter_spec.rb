require 'spec_helper'

describe ActiveRecord::ConnectionAdapters::PerconaMigratorAdapter do
  describe ActiveRecord::ConnectionAdapters::PerconaMigratorAdapter::Column do
    let(:field) { double(:field) }
    let(:default) { double(:default) }
    let(:type) { 'VARCHAR' }
    let(:null) { double(:null) }
    let(:collation) { double(:collation) }

    let(:column) do
      described_class.new(field, default, type, null, collation)
    end

    describe '#adapter' do
      subject { column.adapter }
      it do
        is_expected.to eq(
          ActiveRecord::ConnectionAdapters::PerconaMigratorAdapter
        )
      end
    end
  end

  let(:mysql_adapter) do
    instance_double(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
  end

  let(:logger) { double(:logger, puts: true) }
  let(:connection_options) { { mysql_adapter: mysql_adapter } }

  let(:runner) { instance_double(PerconaMigrator::Runner) }
  let(:cli_generator) do
    instance_double(
      PerconaMigrator::CliGenerator,
      generate: 'percona command'
    )
  end

  let(:config) do
    {
      prepared_statements: '',
      runner: runner,
      cli_generator: cli_generator
    }
  end

  let(:adapter) do
    described_class.new(runner, logger, connection_options, config)
  end

  before do
    allow(runner).to(
      receive(:execute).with('percona command').and_return(true)
    )
    allow(PerconaMigrator::CliGenerator).to(
      receive(:new).and_return(cli_generator)
    )
    allow(PerconaMigrator::Runner).to(
      receive(:new).with(logger)
    ).and_return(runner)
  end

  describe '#supports_migrations?' do
    subject { adapter.supports_migrations? }
    it { is_expected.to be true }
  end

  describe '#new_column' do
    let(:field) { double(:field) }
    let(:default) { double(:default) }
    let(:type) { double(:type) }
    let(:null) { double(:null) }
    let(:collation) { double(:collation) }

    it do
      expect(ActiveRecord::ConnectionAdapters::PerconaMigratorAdapter::Column).to receive(:new)
      adapter.new_column(field, default, type, null, collation)
    end
  end

  describe 'schema statements' do
    describe '#add_index' do
      let(:table_name) { :foo }
      let(:column_name) { :bar_id }
      let(:options) { {} }
      let(:sql) { 'ADD index_type INDEX `index_name` (`bar_id`)' }

      before do
        allow(adapter).to(
          receive(:add_index_options)
          .with(table_name, column_name, options)
          .and_return(['index_name', 'index_type', "`#{column_name}`"])
        )
      end

      it 'passes the built SQL to #execute' do
        expect(adapter).to(
          receive(:execute)
          .with(
            "ALTER TABLE `#{table_name}` ADD index_type INDEX `index_name` (`bar_id`)"
          )
        )
        adapter.add_index(table_name, column_name, options)
      end
    end

    describe '#remove_index' do
      let(:table_name) { :foo }
      let(:options) { { column: :bar_id } }
      let(:sql) { 'DROP INDEX `index_name`' }

      before do
        allow(adapter).to(
          receive(:index_name_for_remove)
          .with(table_name, options)
          .and_return('index_name')
        )
      end

      it 'passes the built SQL to #execute' do
        expect(adapter).to(
          receive(:execute)
          .with("ALTER TABLE `#{table_name}` DROP INDEX `index_name`")
        )
        adapter.remove_index(table_name, options)
      end
    end
  end

  describe '#execute_and_free' do
    let(:mysql_adapter) do
      instance_double(
        ActiveRecord::ConnectionAdapters::Mysql2Adapter,
        raw_connection: true,
        execute: true
      )
    end

    it 'yields the mysql adapter execution result' do
      expect(mysql_adapter).to(
        receive(:execute).with('a sql statement', nil)
      ).and_return('yielded')

      adapter.execute_and_free('a sql statement') do |result|
        expect(result).to eq('yielded')
      end
    end
  end

  describe '#exec_delete' do
    let(:sql) { 'DELETE FROM comments' }
    let(:name) { nil }
    let(:binds) { nil }

    it 'delegates to the mysql adapter' do
      expect(mysql_adapter).to receive(:exec_delete).with(sql, name, binds)
      adapter.exec_delete(sql, name, binds)
    end
  end

  describe '#exec_insert' do
    let(:sql) { 'INSERT INTO comments () VALUES ()' }
    let(:name) { nil }
    let(:binds) { nil }

    it 'delegates to the mysql adapter' do
      expect(mysql_adapter).to receive(:exec_insert).with(sql, name, binds)
      adapter.exec_insert(sql, name, binds)
    end
  end

  describe '#exec_query' do
    let(:sql) { 'SELECT * FROM comments' }
    let(:name) { nil }
    let(:binds) { nil }

    it 'delegates to the mysql adapter' do
      expect(mysql_adapter).to receive(:exec_query).with(sql, name, binds)
      adapter.exec_query(sql, name, binds)
    end
  end

  describe '#last_inserted_id' do
    let(:result) { double(:result) }

    it 'delegates to the mysql adapter' do
      expect(mysql_adapter).to(
        receive(:last_inserted_id).with(result)
      )
      adapter.last_inserted_id(result)
    end
  end

  describe '#tables' do
    let(:name) { nil }
    let(:database) { nil }
    let(:like) { nil }

    it 'delegates to the mysql adapter' do
      expect(mysql_adapter).to receive(:tables).with(name, database, like)
      adapter.tables(name, database, like)
    end
  end

  describe '#select_values' do
    let(:arel) { 'SELECT id FROM comments LIMIT 3' }
    let(:name) { nil }

    it 'delegates to the mysql adapter' do
      expect(mysql_adapter).to receive(:select_values).with(arel, name)
      adapter.select_values(arel, name)
    end
  end

  describe '#percona_execute' do
    let(:name) { nil }

    context 'when an alter statement is provided' do
      let(:table_name) { :comments }
      let(:statement) do
        'ALTER TABLE `comments` CHANGE `some_id` `some_id` INT(11) DEFAULT NULL'
      end

      before do
        allow(cli_generator).to(
          receive(:parse_statement).with(statement)
        ).and_return('percona command')
      end

      it 'passes the built SQL to the CliGenerator' do
        expect(cli_generator).to receive(:parse_statement).with(statement)
        adapter.percona_execute(statement, name)
      end

      it 'runs the command' do
        expect(runner).to receive(:execute).with('percona command')
        adapter.percona_execute(statement, name)
      end

      context 'and providing a name' do
        let(:name) { 'name' }

        it 'passes the built SQL to the CliGenerator' do
          expect(cli_generator).to receive(:parse_statement).with(statement)
          adapter.percona_execute(statement, name)
        end

        it 'runs the command' do
          expect(runner).to receive(:execute).with('percona command')
          adapter.percona_execute(statement, name)
        end
      end
    end

    context 'when a non-alter statement is provided' do
      let(:statement) { 'UPDATE comments SET some_id = NULL' }

      it 'delegates to the mysql adapter' do
        expect(mysql_adapter).to receive(:execute).with(statement, nil)
        adapter.percona_execute(statement, nil)
      end

      context 'and providing a name' do
        it 'delegates to the mysql adapter' do
          expect(mysql_adapter).to receive(:execute).with(statement, 'name')
          adapter.percona_execute(statement, 'name')
        end
      end
    end
  end
end
