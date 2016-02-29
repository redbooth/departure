require 'spec_helper'

describe Lhm::SimpleColumn do
  let(:name) { :some_field_name }
  let(:definition) { :integer }
  let(:column) { described_class.new(name, definition) }

  describe '#attributes' do
    subject { column.attributes }
    it { is_expected.to eq([definition]) }
  end
end
