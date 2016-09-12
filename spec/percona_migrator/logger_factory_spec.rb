require 'spec_helper'

describe PerconaMigrator::LoggerFactory do
  describe '.build' do
    let(:expected_info_message) { "Migrations will execute with PerconaMigrator\nfor more information visit https://github.com/redbooth/percona_migrator" }

    context 'when :verbose is set as true' do
      subject { described_class.build(verbose: true) }
      it { is_expected.to be_a(PerconaMigrator::Logger) }
      it 'tells the user when PerconaMigrator is being used' do
        expect(described_class).to receive(:puts).with(expected_info_message)
        subject
      end
    end

    context 'when :verbose is set as false' do
      subject { described_class.build(verbose: false) }
      it { is_expected.to be_a(PerconaMigrator::NullLogger) }
      it 'tells the user when PerconaMigrator is being used' do
        expect(described_class).not_to receive(:puts)
        subject
      end
    end

    context 'when :verbose is not specified' do
      subject { described_class.build }
      it { is_expected.to be_a(PerconaMigrator::Logger) }
      it 'tells the user when PerconaMigrator is being used' do
        expect(described_class).to receive(:puts).with(expected_info_message)
        subject
      end
    end
  end
end
