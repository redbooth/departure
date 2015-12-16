require 'spec_helper'

describe PerconaMigrator do
  let(:version) { 1 }
  let(:direction) { :up }
  let(:logger) { double(:logger, puts: true) }

  describe '#migrate' do
    before { allow(Kernel).to receive(:system) }

    it 'executes the pt-online-schema-change command' do
      PerconaMigrator.migrate(version, direction, logger)
      expect(Kernel).to have_received(:system).with('pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter "add column \`some_id_field\` INT(11) DEFAULT NULL"')
    end

    context 'when pt-online-schema-change failed' do
      before do
        allow(Kernel).to receive(:system).with('pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter "add column \`some_id_field\` INT(11) DEFAULT NULL"').and_return(false)
      end

      it 'does not execute the mark_as_up rake task' do
        PerconaMigrator.migrate(version, direction, logger)
        expect(Kernel).not_to have_received(:system).with("bundle exec rake db:migrate:mark_as_up VERSION=#{version}")
      end
    end

    context 'when pt-online-schema-change succeeded' do
      before do
        allow(Kernel).to receive(:system).with('pt-online-schema-change --execute --recursion-method=none --alter-foreign-keys-method=auto -h localhost -u root D=percona_migrator_test,t=comments --alter "add column \`some_id_field\` INT(11) DEFAULT NULL"').and_return(true)
      end

      it 'marks the migration as up' do
        PerconaMigrator.migrate(version, direction, logger)
        expect(ActiveRecord::Migrator.current_version).to eq(version)
      end
    end
  end

  describe '#lhm_migration?' do
    subject { PerconaMigrator.lhm_migration?(version) }

    context 'when the migration uses LHM' do
      let(:version) { 1 }
      it { is_expected.to be true }
    end

    context 'when the migration does not use LHM' do
      let(:version) { 7 }
      it { is_expected.to be false }
    end
  end
end
