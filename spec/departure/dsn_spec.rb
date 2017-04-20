require 'spec_helper'

describe PerconaMigrator::DSN do
  let(:database) { 'development' }
  let(:table_name) { 'comments' }

  describe '#to_s' do
    subject { described_class.new(database, table_name).to_s }
    it { is_expected.to eq('D=development,t=comments') }
  end
end
