require 'spec_helper'

describe PerconaMigrator::ConnectionDetails do
  let(:connection_details) { described_class.new(connection_data) }

    around do |example|
      ClimateControl.modify(env_var) do
        example.run
      end
    end

    describe '#to_s' do
      subject { connection_details.to_s }
      let(:connection_data) do
        {
          host: 'foo.com',
          user: 'root',
          database: 'dummy_test'
        }
      end

      context 'when the host is not specified' do
        let(:env_var) { {} }
        let(:connection_data) { { user: 'root', database: 'dummy_test' } }

        it { is_expected.to include('-h localhost') }
      end

      context 'when the host is specified' do
        let(:env_var) { {} }
        let(:connection_data) do
          { host: 'foo.com:3306', user: 'root', database: 'dummy_test' }
        end

        it { is_expected.not_to include('-h localhost') }
        it { is_expected.to include('-h foo.com:3306') }
      end

      context 'when specifying PERCONA_DB_HOST' do
        let(:env_var) { { PERCONA_DB_HOST: 'foo.com:3306' } }
        it { is_expected.to include('h foo.com:3306') }
      end

      context 'when specifying PERCONA_DB_USER' do
        let(:env_var) { { PERCONA_DB_USER: 'percona' } }
        it { is_expected.to include('-u percona') }
      end

      context 'when specifying PERCONA_DB_PASSWORD' do
        let(:env_var) { { PERCONA_DB_PASSWORD: 'password' } }
        it { is_expected.to include('-p password') }
      end
    end

  describe '#database' do
    subject { connection_details.database }
    let(:connection_data) do
      {
        host: 'localhost',
        user: 'root',
        database: 'dummy_test'
      }
    end

    context 'when specifying PERCONA_DB_NAME' do
      let(:env_var) { { PERCONA_DB_NAME: 'dummy_database' } }
      it { is_expected.to eq('dummy_database') }
    end
  end
end
