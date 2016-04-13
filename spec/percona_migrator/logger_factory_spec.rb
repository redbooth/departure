require 'spec_helper'

describe PerconaMigrator::LoggerFactory do
  describe '.build' do
    subject { described_class.build(config) }

    context 'when :verbose is set as true' do
      let(:config) { { verbose: true } }
      it { is_expected.to be_a(PerconaMigrator::Logger) }
    end

    context 'when :verbose is set as false' do
      let(:config) { { verbose: false } }
      it { is_expected.to be_a(PerconaMigrator::NullLogger) }
    end

    context 'when :verbose is not specified' do
      let(:config) { {} }
      it { is_expected.to be_a(PerconaMigrator::Logger) }
    end
  end
end
