require 'spec_helper'

describe PerconaMigrator::CliGenerator do
  let(:cli_generator) { described_class.new(connection_details) }
  let(:connection_details) do
    instance_double(
      PerconaMigrator::ConnectionDetails,
      database: 'dummy_test',
      to_s: '-h localhost -u root'
    )
  end

  let(:table_name) { 'tasks' }
  let(:statement) { 'ALTER TABLE `tasks` ADD foo INT' }

  describe '#generate' do
    subject do
      ClimateControl.modify(env_var) do
        cli_generator.generate(table_name, statement)
      end
    end

    context 'when no options are provided' do
      let(:env_var) { {} }

      it { is_expected.to include('pt-online-schema-change') }
      it { is_expected.not_to include('ALTER TABLE') }
      it { is_expected.to include('--execute') }
      it { is_expected.to include('--alter-foreign-keys-method=auto') }

      it { is_expected.to include("t=#{table_name}") }
      it { is_expected.to include("D=#{connection_details.database}") }
    end

    context 'when options are provided' do
      let(:env_var) { { PT_ARGS: '--chunk-time=1' } }
      it { is_expected.to include('--chunk-time=1') }
    end

    context 'when the option has a default' do
      let(:env_var) { { PT_ARGS: '--alter-foreign-keys-method=drop_swap' } }

      it { is_expected.to include('--alter-foreign-keys-method=drop_swap') }
      it { is_expected.not_to include('--alter-foreign-keys-method=auto') }
    end

    context 'when multiple options are provided' do
      let(:env_var) { { PT_ARGS: '--chunk-time=1 --max-lag=2' } }
      it { is_expected.to include('--chunk-time=1 --max-lag=2') }
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
        to_s: "D=#{connection_details.database},t=#{table_name}"
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
      allow(PerconaMigrator::AlterArgument)
        .to receive(:new).and_return(alter_argument)
    end

    it 'populates the DSN' do
      cli_generator.parse_statement(statement)
      expect(dsn).to have_received(:to_s)
    end

    it 'gets the proper alter argument' do
      cli_generator.parse_statement(statement)
      expect(alter_argument).to have_received(:to_s)
    end

    it { is_expected.to include('pt-online-schema-change') }
    it { is_expected.not_to include('ALTER TABLE') }
    it { is_expected.to include('--execute') }
    it { is_expected.to include('--alter-foreign-keys-method=auto') }
    it { is_expected.to include('--no-check-alter') }

    it { is_expected.to include("t=#{table_name}") }
    it { is_expected.to include("D=#{connection_details.database}") }
  end
end
