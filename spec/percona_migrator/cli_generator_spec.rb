require 'spec_helper'

describe PerconaMigrator::CliGenerator do
  let(:cli_generator) { described_class.new(connection_data) }
  let(:connection_data) do
    {
      host: 'localhost',
      user: 'root',
      database: 'dummy_test'
    }
  end
  let(:table_name) { 'tasks' }
  let(:statement) { 'ALTER TABLE `tasks` ADD foo INT' }

  describe '#generate' do
    subject { cli_generator.generate(table_name, statement) }

    describe 'connection details' do
      context 'when the host is not specified' do
        let(:connection_data) { { user: 'root', database: 'dummy_test' } }
        it { is_expected.to include('-h localhost') }
      end

      context 'when the host is specified' do
        let(:connection_data) do
          { host: 'foo.com:3306', user: 'root', database: 'dummy_test' }
        end

        it { is_expected.not_to include('-h localhost') }
        it { is_expected.to include('-h foo.com:3306') }
      end

      context 'when specifying PERCONA_DB_HOST' do
        before { ENV['PERCONA_DB_HOST'] = 'foo.com:3306' }
        after { ENV.delete('PERCONA_DB_HOST') }

        it { is_expected.to include('h foo.com:3306') }
      end

      context 'when specifying PERCONA_DB_USER' do
        before { ENV['PERCONA_DB_USER'] = 'percona' }
        after { ENV.delete('PERCONA_DB_USER') }

        it { is_expected.to include('-u percona') }
      end

      context 'when specifying PERCONA_DB_PASSWORD' do
        before { ENV['PERCONA_DB_PASSWORD'] = 'password' }
        after { ENV.delete('PERCONA_DB_PASSWORD') }

        it { is_expected.to include('-p password') }
      end

      context 'when specifying PERCONA_DB_NAME' do
        before { ENV['PERCONA_DB_NAME'] = 'dummy_database' }
        after { ENV.delete('PERCONA_DB_NAME') }

        it { is_expected.to include('D=dummy_database') }
      end
    end

    describe 'the command' do
      it { is_expected.to include('pt-online-schema-change') }
      it { is_expected.not_to include('ALTER TABLE') }
      it { is_expected.to include('--execute') }
      it { is_expected.to include('--alter-foreign-keys-method=auto') }

      it { is_expected.to include("t=#{table_name}") }
      it { is_expected.to include("D=#{connection_data[:database]}") }
    end
  end

  describe '#parse_statement' do
    subject { cli_generator.parse_statement(statement) }

    let(:statement) do
      'ALTER TABLE `comments` CHANGE `some_id` `some_id` INT(11) DEFAULT NULL'
    end
    let(:table_name) { 'comments' }
    let(:dsn) do
      instance_double(
        PerconaMigrator::DSN,
        to_s: "D=#{connection_data[:database]},
        t=#{table_name}"
      )
    end
    let(:alter_argument) do
      instance_double(
        PerconaMigrator::AlterArgument,
        to_s: 'CHANGE `some_id` `some_id` INT(11) DEFAULT NULL',
        table_name: table_name
      )
    end

    before do
      allow(PerconaMigrator::DSN).to receive(:new).and_return(dsn)
      allow(PerconaMigrator::AlterArgument).to(
        receive(:new).and_return(alter_argument)
      )
    end

    it 'populates the DSN' do
      cli_generator.parse_statement(statement)
      expect(dsn).to have_received(:to_s)
    end

    it 'gets the proper alter argument' do
      cli_generator.parse_statement(statement)
      expect(alter_argument).to have_received(:to_s)
    end

    describe 'the command' do
      it { is_expected.to include('pt-online-schema-change') }
      it { is_expected.not_to include('ALTER TABLE') }
      it { is_expected.to include('--execute') }
      it { is_expected.to include('--alter-foreign-keys-method=auto') }
      it { is_expected.to include('--no-check-alter') }

      it { is_expected.to include("t=#{table_name}") }
      it { is_expected.to include("D=#{connection_data[:database]}") }
    end
  end

  describe PerconaMigrator::DSN do
    let(:database) { 'development' }
    let(:table_name) { 'comments' }

    describe '#to_s' do
      subject { described_class.new(database, table_name).to_s }
      it { is_expected.to eq('D=development,t=comments') }
    end
  end
end
