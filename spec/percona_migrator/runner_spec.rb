require 'byebug'
require 'spec_helper'

describe PerconaMigrator::Runner do
  let(:command) { 'pt-online-schema-change command' }
  let(:logger) { instance_double(Logger, info: true) }

  let(:runner) { described_class.new(logger) }

  describe '#execute' do
    let(:status) do
      instance_double(Process::Status, exitstatus: 0, signaled?: false)
    end
    let(:stdout) { double(:stdout, read: 'command output') }
    let(:process) { instance_double(Thread, value: status) }

    before do
      allow(Open3).to(
        receive(:popen2).with(command).and_yield(nil, stdout, process)
      )
    end

    it 'executes the pt-online-schema-change command' do
      runner.execute(command)
      expect(Open3).to have_received(:popen2).with(command)
    end

    it 'returns the command status' do
      expect(runner.execute(command)).to eq(status)
    end

    it 'logs that the execution started' do
      runner.execute(command)
      expect(logger).to have_received(:info).with('command output')
    end

    it 'logs that the command\'s output' do
      runner.execute(command)
      expect(logger).to have_received(:info).with('command output')
    end

    context 'when the execution was succsessfull' do
      it 'logs it as success' do
        runner.execute(command)
        expect(logger).to have_received(:info).with(/Done!/)
      end
    end

    context 'when the execution failed' do
      let(:status) do
        instance_double(Process::Status, exitstatus: 1, signaled?: false)
      end

      it 'logs it as failure' do
        runner.execute(command)
        expect(logger).to have_received(:info).with(/Failed!/)
      end
    end

    context 'when the command\'s exit status could not be retrieved' do
      let(:status) { nil }
      before { allow(Kernel).to receive(:warn).and_return(true) }

      it 'writes to the STDERR' do
        runner.execute(command)
        expect(Kernel).to have_received(:warn)
      end
    end

    context 'when the command did not catch a signal' do
      let(:status) do
        instance_double(Process::Status, exitstatus: 1, signaled?: true)
      end
      before { allow(Kernel).to receive(:warn).and_return(true) }

      it 'writes to the STDERR' do
        runner.execute(command)
        expect(Kernel).to have_received(:warn)
      end
    end
  end
end
