require 'spec_helper'

describe PerconaMigrator do
  describe '.config' do
    subject { described_class.config }
    it { is_expected.to be_a(PerconaMigrator::Configuration) }
  end
end
