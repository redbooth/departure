require 'spec_helper'

describe PerconaMigrator::Runner do
  let(:command) { 'pt-online-schema-change command' }
  let(:logger) do
    instance_double(ActiveRecord::Migration, write: true, say: true)
  end
  let(:cli_generator) { instance_double(PerconaMigrator::CliGenerator) }
  let(:mysql_adapter) do
    instance_double(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
  end

  let(:runner) { described_class.new(logger, cli_generator, mysql_adapter) }

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
    let(:status) do
      instance_double(
        Process::Status,
        exitstatus: 0,
        signaled?: false,
        success?: true
      )
    end
    let(:stdout) { double(:stdout, read: 'command output') }
    let(:stderr) { double(:stderr, read: nil) }
    let(:wait_thread) { instance_double(Thread, value: status) }

    before do
      allow(Open3).to(
        receive(:popen3)
        .with(command)
        .and_yield(nil, stdout, stderr, wait_thread)
      )
    end

    it 'executes the pt-online-schema-change command' do
      runner.execute(command)
      expect(Open3).to have_received(:popen3).with(command)
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

    it 'logs the command\'s output' do
      runner.execute(command)
      expect(logger).to have_received(:write).with('command output')
    end

    context 'when the execution was succsessfull' do
      it 'prints a new line' do
        runner.execute(command)
        expect(logger).to have_received(:write).twice.with(/\n/)
      end
    end

    context 'when the execution failed' do
      let(:status) do
        instance_double(
          Process::Status,
          exitstatus: 1,
          signaled?: false,
          success?: false
        )
      end

      it 'raises a PerconaMigrator::Error' do
        expect { runner.execute(command) }.to(
          raise_exception(PerconaMigrator::Error)
        )
      end
    end

    context 'when the command\'s exit status could not be retrieved' do
      let(:status) { nil }

      it 'raises a NoStatusError' do
        expect { runner.execute(command) }.to(
          raise_exception(PerconaMigrator::NoStatusError)
        )
      end
    end

    context 'when the command was signaled' do
      let(:status) do
        instance_double(
          Process::Status,
          exitstatus: 1,
          signaled?: true,
          success?: false
        )
      end

      it 'raises a SignalError specifying the status' do
        expect { runner.execute(command) }.to(
          raise_exception(PerconaMigrator::SignalError, status.to_s)
        )
      end
    end

    context 'when pt-online-schema-change is not installed' do
      let(:status) do
        instance_double(
          Process::Status,
          exitstatus: 127,
          signaled?: false,
          success?: false
        )
      end
      let(:stderr) { double(:stderr, read: 'command not found') }

      it 'raises a detailed CommandNotFoundError' do
        expect { runner.execute(command) }.to(
          raise_exception(
            PerconaMigrator::CommandNotFoundError,
            /Please install pt-online-schema-change/
          )
        )
      end
    end
  end
end
