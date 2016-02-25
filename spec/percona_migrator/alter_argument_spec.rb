require 'spec_helper'

describe PerconaMigrator::AlterArgument do
  let(:statement) { 'ADD INDEX dummy_index (some_id_field)' }
  let(:alter_argument) { described_class.new(statement) }

  subject { alter_argument.to_s }
  it { is_expected.to eq('--alter "ADD INDEX dummy_index (some_id_field)"') }
end
