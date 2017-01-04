require 'spec_helper'

describe PerconaMigrator::Option do
  describe '.from_string' do
    it 'gets the name and value' do
      expect(described_class).to receive(:new).with('arg', 'value')
      described_class.from_string('--arg=value')
    end
  end

  describe '#==' do
    subject { option == other_option }
    let(:option) { described_class.new('arg', 'bar') }

    context 'when the options have different name' do
      let(:other_option) { described_class.new('other_arg', 'lol') }
      it { is_expected.to be_falsy }
    end

    context 'when the options have the same name' do
      let(:other_option) { described_class.new('arg', 'lol') }
      it { is_expected.to be_truthy }
    end
  end

  describe '#eql?' do
    subject { option.eql?(other_option) }
    let(:option) { described_class.new('arg', 'bar') }

    context 'when the options have different name' do
      let(:other_option) { described_class.new('other_arg', 'lol') }
      it { is_expected.to be_falsy }
    end

    context 'when the options have the same name' do
      let(:other_option) { described_class.new('arg', 'lol') }
      it { is_expected.to be_truthy }
    end
  end

  describe '#hash' do
    subject { option.hash }
    let(:option) { described_class.new('arg', 'bar') }

    it { is_expected.to eq('arg'.hash) }
  end

  describe '#to_s' do
    subject { option.to_s }

    context 'when there is no value' do
      let(:option) { described_class.new('arg') }
      it { is_expected.to eq('--arg') }
    end

    context 'when there is value' do
      let(:option) { described_class.new('arg', 'bar') }
      it { is_expected.to eq('--arg=bar') }
    end
  end
end
