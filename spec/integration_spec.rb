require 'spec_helper'

describe PerconaMigrator do
  before { allow(Kernel).to receive(:system) }

  let(:direction) { :up }
  let(:logger) { double(:logger, puts: true) }
  let(:mark_as_up) { "bundle exec rake db:migrate:mark_as_up VERSION=#{version}" }

  subject { described_class.migrate(version, direction, logger) }

  it 'has a version number' do
    expect(PerconaMigrator::VERSION).not_to be nil
  end

  context 'creating/removing columns' do
    let(:version) { 1 }

    it 'runs pt-online-schema-change' do
      described_class.migrate(version, direction, logger)
      expect(Kernel).to(
        have_received(:system)
        .with(include('pt-online-schema-change'))
      )
    end

    it 'executes the migration' do
      described_class.migrate(version, direction, logger)
      expect(Kernel).to(
        have_received(:system)
        .with(include('--execute'))
      )
    end

    it 'does not define --recursion-method' do
      described_class.migrate(version, direction, logger)
      expect(Kernel).to(
        have_received(:system)
        .with(include('--recursion-method=none'))
      )
    end

    it 'sets the --alter-foreign-keys-method option to auto' do
      described_class.migrate(version, direction, logger)
      expect(Kernel).to(
        have_received(:system)
        .with(include('--alter-foreign-keys-method=auto'))
      )
    end

    context 'creating column' do
      let(:direction) { :up }

      it 'executes the percona command' do
        described_class.migrate(version, direction, logger)
        expect(Kernel).to(
          have_received(:system)
          .with(include("--alter \"add column \\`some_id_field\\` INT(11) DEFAULT NULL\""))
        )
      end

      it 'marks the migration as up' do
        allow(Kernel).to receive(:system).with("pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter \"add column \\`some_id_field\\` INT(11) DEFAULT NULL\"").and_return(true)

        described_class.migrate(version, direction, logger)

        expect(Kernel).to(
          have_received(:system)
          .with(mark_as_up)
        )
      end
    end

    context 'droping column' do
      let(:direction) { :down }

      it 'executes the percona command' do
        described_class.migrate(version, direction, logger)
        expect(Kernel).to(
          have_received(:system)
          .with(include("--alter \"drop \\`some_id_field\\`\""))
        )
      end

      it 'marks the migration as up' do
        allow(Kernel).to receive(:system).with("pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter \"drop \\`some_id_field\\`\"").and_return(true)

        described_class.migrate(version, direction, logger)

        expect(Kernel).to(
          have_received(:system)
          .with(include(mark_as_up))
        )
      end
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

      context 'when there is password' do
        it 'executes the percona command with the right connection details' do
          described_class.migrate(version, direction, logger)
          expect(Kernel).to(
            have_received(:system)
            .with(include("-h #{host} -u #{user} -p #{password} D=#{db_name},t=comments" ))
          )
        end
      end

      context 'when there is no password' do
        before do
          allow(ENV).to receive(:[]).with('PERCONA_DB_PASSWORD').and_return(nil)
        end

        it 'executes the percona command with the right connection details' do
          described_class.migrate(version, direction, logger)
          expect(Kernel).to(
            have_received(:system)
            .with(include("-h #{host} -u #{user} D=#{db_name},t=comments"))
          )
        end
      end
    end
  end

  context 'adding/removing indexes' do
    let(:version) { 2 }

    context 'adding indexes' do
      let(:direction) { :up }

      it 'executes the percona command' do
        described_class.migrate(version, direction, logger)
        expect(Kernel).to(
          have_received(:system)
          .with(include("--alter \"add index \\`index_comments_on_some_id_field\\` (\\`some_id_field\\`)\""))
        )
      end

      it 'marks the migration as up' do
        allow(Kernel).to receive(:system).with("pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter \"add index \\`index_comments_on_some_id_field\\` (\\`some_id_field\\`)\"").and_return(true)

        described_class.migrate(version, direction, logger)

        expect(Kernel).to(
          have_received(:system)
          .with(include(mark_as_up))
        )
      end
    end

    context 'removing indexes' do
      let(:direction) { :down }

      it 'executes the percona command' do
        described_class.migrate(version, direction, logger)
        expect(Kernel).to(
          have_received(:system)
          .with(include("--alter \"drop index \\`index_comments_on_some_id_field\\`\""))
        )
      end

      it 'marks the migration as up' do
        allow(Kernel).to receive(:system).with("pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter \"drop index \\`index_comments_on_some_id_field\\`\"").and_return(true)

        described_class.migrate(version, direction, logger)

        expect(Kernel).to(
          have_received(:system)
          .with(include(mark_as_up))
        )
      end
    end
  end

  context 'adding/removing unique indexes' do
    let(:version) { 3 }

    context 'adding indexes' do
      let(:direction) { :up }

      it 'executes the percona command' do
        described_class.migrate(version, direction, logger)
        expect(Kernel).to(
          have_received(:system)
          .with(include("--alter \"add unique index \\`index_comments_on_some_id_field\\` (\\`some_id_field\\`)\""))
        )
      end

      it 'marks the migration as up' do
        allow(Kernel).to receive(:system).with("pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter \"add unique index \\`index_comments_on_some_id_field\\` (\\`some_id_field\\`)\"").and_return(true)

        described_class.migrate(version, direction, logger)

        expect(Kernel).to(
          have_received(:system)
          .with(include(mark_as_up))
        )
      end
    end

    context 'removing indexes' do
      let(:direction) { :down }

      it 'executes the percona command' do
        described_class.migrate(version, direction, logger)
        expect(Kernel).to(
          have_received(:system)
          .with(include("--alter \"drop index \\`index_comments_on_some_id_field\\`\""))
        )
      end

      it 'marks the migration as up' do
        allow(Kernel).to receive(:system).with("pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter \"drop index \\`index_comments_on_some_id_field\\`\"").and_return(true)

        described_class.migrate(version, direction, logger)

        expect(Kernel).to(
          have_received(:system)
          .with(include(mark_as_up))
        )
      end
    end
  end

  context 'working with ddl' do
    let(:version) { 4 }

    context 'up' do
      let(:direction) { :up }

      it 'executes the percona command' do
        described_class.migrate(version, direction, logger)
        expect(Kernel).to(
          have_received(:system)
          .with(include("--alter \"my up ddl statement, my up ddl statement\""))
        )
      end

      it 'marks the migration as up' do
        allow(Kernel).to receive(:system).with("pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter \"my up ddl statement, my up ddl statement\"").and_return(true)

        described_class.migrate(version, direction, logger)

        expect(Kernel).to(
          have_received(:system)
          .with(include(mark_as_up))
        )
      end
    end

    context 'down' do
      let(:direction) { :down }

      it 'executes the percona command' do
        described_class.migrate(version, direction, logger)
        expect(Kernel).to(
          have_received(:system)
          .with(include("--alter \"my down ddl statement, my down ddl statement\""))
        )
      end

      it 'marks the migration as up' do
        allow(Kernel).to receive(:system).with("pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter \"my down ddl statement, my down ddl statement\"").and_return(true)

        described_class.migrate(version, direction, logger)

        expect(Kernel).to(
          have_received(:system)
          .with(include(mark_as_up))
        )
      end
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
