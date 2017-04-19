require 'spec_helper'
require 'tempfile'

describe Departure::Runner do
  let(:command) { 'pt-online-schema-change command' }
  let(:logger) do
    instance_double(
      Departure::Logger,
      write: true,
      write_no_newline: true,
      say: true
    )
  end
  let(:cli_generator) { instance_double(Departure::CliGenerator) }
  let(:mysql_adapter) do
    instance_double(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
  end
  let(:config) do
    instance_double(
      Departure::Configuration,
      error_log_path: 'departure_error.log'
    )
  end

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
    let(:temp_file) do
      file = Tempfile.new('faked_stdout')
      file.write('hello world\ntodo roto')
      file.rewind
      file.close
      file
    end
    let(:status) do
      instance_double(
        Process::Status,
        exitstatus: 0,
        signaled?: false,
        success?: true
      )
    end
    let(:stdout) { temp_file.open }
    let(:wait_thread) { instance_double(Thread, value: status) }
    let(:expected_command) { "#{command} 2> #{config.error_log_path}" }

    before do
      allow(Open3).to(
        receive(:popen3)
        .with(expected_command)
        .and_yield(nil, stdout, nil, wait_thread)
      )
    end

    it 'executes the pt-online-schema-change command' do
      runner.execute(command)

      expect(Open3).to have_received(:popen3).with(expected_command)
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

      expect(logger).to have_received(:write).with("\n").twice.times
      expect(logger).to have_received(:write_no_newline).with("hello wo")
      expect(logger).to have_received(:write_no_newline).with("rld\\ntod")
      expect(logger).to have_received(:write_no_newline).with("o roto")
    end

    context 'when the execution was successful' do
      it 'prints a new line' do
        runner.execute(command)
        expect(logger).to have_received(:write).twice.times.with(/\n/)
      end
    end

    context 'on failure' do
      let(:expected_command) { "#{command} 2> #{config.error_log_path}" }

      before do
        allow(Open3).to(
          receive(:popen3)
          .with(expected_command)
          .and_call_original
        )
      end

      context 'when the execution failed' do
        let(:command) { 'sh -c \'echo ROTO >/dev/stderr && false\'' }

        it 'raises a Departure::Error' do
          expect { runner.execute(command) }
            .to raise_exception(Departure::Error, "ROTO\n")
        end
      end

      context 'when the command was signaled' do
        let(:command) { 'kill -9 $$' }

        it 'raises a SignalError specifying the status' do
          expect { runner.execute(command) }
            .to raise_exception(Departure::SignalError)
        end
      end

      context 'when pt-online-schema-change is not installed' do
        let(:command) { 'whatevarrr666' }

        it 'raises a detailed CommandNotFoundError' do
          expect { runner.execute(command) }
            .to raise_exception(
              Departure::CommandNotFoundError,
              /Please install pt-online-schema-change/
            )
        end
      end
    end
  end
end
