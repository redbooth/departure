require 'byebug'
require 'spec_helper'

describe PerconaMigrator do
  before(:all) do
    @initial_migration_paths = ActiveRecord::Migrator.migrations_paths
    migration_fixtures = File.expand_path('../fixtures/migrate/', __FILE__)
    ActiveRecord::Migrator.migrations_paths = [migration_fixtures]
  end

  before do
    allow(ActiveRecord::Migrator).to receive(:current_version).and_return(0)
  end

  after(:all) do
    ActiveRecord::Migrator.migrations_paths = @initial_migration_paths
  end

  let(:direction) { :up }
  subject { described_class.migrate(version, direction) }

  it 'has a version number' do
    expect(PerconaMigrator::VERSION).not_to be nil
  end

  context 'creating/removing columns' do
    let(:version) { 1 }

    it { is_expected.to include('pt-online-schema-change') }
    it { is_expected.to include('--execute') }
    it { is_expected.to include('--recursion-method=none') }
    it { is_expected.to include('--alter-foreign-keys-method=auto') }

    context 'creating column' do
      let(:direction) { :up }
      it { is_expected.to include('--alter "add column \`some_id_field\` INT(11) DEFAULT NULL"' )}
    end

    context 'droping column' do
      let(:direction) { :down }
      it { is_expected.to include('--alter "drop \`some_id_field\`"' )}
    end

    context 'specifing connection vars and parsing tablename' do
      let(:host)      { 'test_host' }
      let(:user)      { 'test_user' }
      let(:password)  { 'test_password' }
      let(:db_name)   { 'test_db' }

      before do
        allow(ENV).to receive(:[]).with('PERCONA_DB_HOST').and_return(host)
        allow(ENV).to receive(:[]).with('PERCONA_DB_USER').and_return(user)
        allow(ENV).to receive(:[]).with('PERCONA_DB_PASSWORD').and_return(password)
        allow(ENV).to receive(:[]).with('PERCONA_DB_NAME').and_return(db_name)
      end

      it { is_expected.to include("-h #{host} -u #{user} -p #{password} D=#{db_name},t=comments" )}
    end
  end

  context 'adding/removing indexes' do
    let(:version) { 2 }

    context 'adding indexes' do
      let(:direction) { :up }
      it { is_expected.to include('--alter "add index \`index_comments_on_some_id_field\` (\`some_id_field\`)"') }
    end

    context 'removing indexes' do
      let(:direction) { :down }
      it { is_expected.to include('--alter "drop index \`index_comments_on_some_id_field\`"') }
    end
  end

  context 'adding/removing unique indexes' do
    let(:version) { 3 }

    context 'adding indexes' do
      let(:direction) { :up }
      it { is_expected.to include('--alter "add unique index \`index_comments_on_some_id_field\` (\`some_id_field\`)"') }
    end

    context 'removing indexes' do
      let(:direction) { :down }
      it { is_expected.to include('--alter "drop index \`index_comments_on_some_id_field\`"') }
    end
  end

  context 'working with ddl' do
    let(:version) { 4 }
    context 'up' do
      let(:direction) { :up }
      it { is_expected.to include('--alter "my up ddl statement, my up ddl statement"') }
    end

    context 'down' do
      let(:direction) { :down }
      it { is_expected.to include('--alter "my down ddl statement, my down ddl statement"') }
    end
  end

  context 'working with an empty migration' do
    let(:version) { 5 }
    it 'errors' do
      expect { subject }.to raise_error(/no statements were parsed/i)
    end
  end

  context 'working with broken migration' do
    let(:version) { 6 }
    it 'errors' do
      expect { subject }.to raise_error(/don't know how to parse/i)
    end
  end

  context 'working with non-lhm migration' do
    let(:version) { 7 }
    it 'errors' do
      expect { subject }.to raise_error(/passed non-lhm migration/i)
    end
  end

  context 'detecting lhm migrations' do
    subject { described_class.lhm_migration?(version) }

    context 'lhm migration' do
      let(:version) { 1 }
      it { is_expected.to be_truthy }
    end

    context 'working with an non lhm migration' do
      let(:version) { 7 }
      it { is_expected.to be_falsey }
    end
  end

end
