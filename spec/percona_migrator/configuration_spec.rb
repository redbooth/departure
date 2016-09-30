require 'spec_helper'

describe PerconaMigrator::Configuration do
  describe '#initialize' do
    its(:tmp_path) { is_expected.to eq('percona_migrator_error.log') }
  end

  describe '#tmp_path' do
    subject { described_class.new.tmp_path }
    it { is_expected.to eq('percona_migrator_error.log') }
  end

  describe '#tmp_path=' do
    subject { described_class.new.tmp_path = 'foo.log' }
    it { is_expected.to eq('foo.log') }
  end
end
