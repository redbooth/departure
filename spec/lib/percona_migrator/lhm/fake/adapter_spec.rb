require 'spec_helper'

# TODO: Support NOT NULL
describe PerconaMigrator::Lhm::Fake::Adapter do
  let(:migration) { double(:migration) }
  let(:table_name) { :comments }

  let(:adapter) { described_class.new(migration, table_name) }

  describe '#add_column' do
    before do
      allow(migration).to(
        receive(:add_column).with(table_name, column_name, type, options)
      )
    end

    before { adapter.add_column(column_name, definition) }

    context 'with :integer' do
      let(:definition) { 'INT(11) DEFAULT NULL' }
      let(:column_name) { :some_id_field }
      let(:type) { :integer }
      # Add WithLimit and WithDefault contexts
      let(:options) { { limit: 4, default: nil } }

      it 'calls #add_column in the migration' do
        expect(migration).to(
          have_received(:add_column)
          .with(table_name, column_name, type, options)
        )
      end
    end

    context 'with :string' do
      let(:definition) { 'VARCHAR(255)' }
      let(:column_name) { :body }
      let(:type) { :string }
      let(:options) { { limit: 255, default: nil } }

      it 'calls #add_column in the migration' do
        expect(migration).to(
          have_received(:add_column)
          .with(table_name, column_name, type, options)
        )
      end

      context 'when a default value is specified' do
        let(:definition) { "VARCHAR(255) DEFAULT 'foo'" }
        let(:options) { { limit: 255, default: 'foo' } }

        it 'calls #add_column in the migration' do
          expect(migration).to(
            have_received(:add_column)
            .with(table_name, column_name, type, options)
          )
        end
      end
    end

    context 'with :date' do
      let(:definition) { 'DATE DEFAULT NULL' }
      let(:column_name) { :due_on }
      let(:type) { :date }
      let(:options) { { limit: nil, default: nil } }

      it 'calls #add_column in the migration' do
        expect(migration).to(
          have_received(:add_column)
          .with(table_name, column_name, type, options)
        )
      end
    end

    context 'with :datetime' do
      let(:definition) { 'DATETIME' }
      let(:column_name) { :created_at }
      let(:type) { :datetime }
      let(:options) { { limit: nil, default: nil } }

      it 'calls #add_column in the migration' do
        expect(migration).to(
          have_received(:add_column)
          .with(table_name, column_name, type, options)
        )
      end
    end
  end
end
