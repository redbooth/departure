require 'spec_helper'

describe PerconaMigrator::Lhm::Fake::Adapter do
  let(:migration) { double(:migration) }
  let(:table_name) { :comments }

  let(:adapter) { described_class.new(migration, table_name) }

  describe '#add_column' do
    let(:definition) { nil }
    let(:column_name) { :some_id_field }
    let(:type) { :integer }
    let(:options) { { limit: 11, default: nil } }

    before do
      allow(migration).to(
        receive(:add_column).with(table_name, column_name, type, options)
      )
    end

    before { adapter.add_column(column_name, definition) }

    it 'calls #add_column in the migration' do
      expect(migration).to(
        have_received(:add_column).with(table_name, column_name, type, options)
      )
    end
  end
end
