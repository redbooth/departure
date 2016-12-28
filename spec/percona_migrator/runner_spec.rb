require 'spec_helper'
require 'tempfile'

describe PerconaMigrator::Runner do
  let(:command) { 'pt-online-schema-change command' }
  let(:logger) do
    instance_double(
      PerconaMigrator::Logger,
      write: true,
      say: true
    )
  end
  let(:cli_generator) { instance_double(PerconaMigrator::CliGenerator) }
  let(:mysql_adapter) do
    instance_double(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
  end
  let(:config) { instance_double(PerconaMigrator::Configuration) }

  let(:runner) { described_class.new(logger, cli_generator, mysql_adapter, config) }

  describe '#query' do
  end

  describe '#affected_rows' do
    let(:mysql_client) { double(:mysql_client) }

    before do
      allow(mysql_adapter).to receive(:raw_connection).and_return(mysql_client)
    end

    it 'delegates to the MySQL adapter\'s client' do
      expect(mysql_client).to receive(:affected_rows)
      runner.affected_rows
    end
  end

  describe '#execute' do
    let(:status) { instance_double(Process::Status) }
    let(:cmd) { instance_double(PerconaMigrator::Command, run: status) }

    before do
      allow(PerconaMigrator::Command)
        .to receive(:new).with(command, config, logger).and_return(cmd)
    end

    it 'executes the pt-online-schema-change command' do
      runner.execute(command)
      expect(cmd).to have_received(:run)
    end

    it 'returns the command status' do
      expect(runner.execute(command)).to eq(status)
    end

    it 'logs that the execution started' do
      runner.execute(command)
      expect(logger).to have_received(:say).with(
        "Running pt-online-schema-change command\n\n",
        true
      )
    end
  end
end
