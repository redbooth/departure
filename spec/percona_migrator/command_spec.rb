require 'spec_helper'

describe PerconaMigrator::Command do
  describe '#run' do
    let(:command) { 'pt-online-schema-change command' }
    let(:config) do
      instance_double(
        PerconaMigrator::Configuration,
        error_log_path: 'percona_migrator_error.log'
      )
    end
    let(:logger) { instance_double(PerconaMigrator::Logger) }

    before do
      allow(logger).to receive(:write_no_newline).with(anything).and_return(true)
    end

    let(:runner) { described_class.new(command, config, logger) }

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
      runner.run
      expect(Open3).to have_received(:popen3).with(expected_command)
    end

    it 'returns the command status' do
      expect(runner.run).to eq(status)
    end

    it 'logs the command\'s output' do
      runner.run

      expect(logger).to have_received(:write_no_newline).with("hello wo")
      expect(logger).to have_received(:write_no_newline).with("rld\\ntod")
      expect(logger).to have_received(:write_no_newline).with("o roto")
    end

    context 'on failure' do
      before do
        allow(Open3).to(
          receive(:popen3)
          .with(expected_command)
          .and_call_original
        )
      end

      context 'when the execution failed' do
        let(:command) { 'sh -c \'echo ROTO >/dev/stderr && false\'' }

        it 'raises a PerconaMigrator::Error' do
          expect { runner.run }
            .to raise_exception(PerconaMigrator::Error, "ROTO\n")
        end
      end

      context 'when the command was signaled' do
        let(:command) { 'kill -9 $$' }

        it 'raises a SignalError specifying the status' do
          expect { runner.run }
            .to raise_exception(PerconaMigrator::SignalError)
        end
      end

      context 'when pt-online-schema-change is not installed' do
        let(:command) { 'whatevarrr666' }

        it 'raises a detailed CommandNotFoundError' do
          expect { runner.run }.to raise_exception(
            PerconaMigrator::CommandNotFoundError,
            /Please install pt-online-schema-change/
          )
        end
      end
    end
  end
end
