require 'byebug'
require 'spec_helper'

# TODO: Support NOT NULL
# TODO: Add WithLimit and WithDefault contexts
# TODO: What about ENUM?
describe PerconaMigrator::Lhm::Fake::Adapter, '#add_column' do
  let(:migration) { double(:migration) }
  let(:table_name) { :comments }

  let(:adapter) { described_class.new(migration, table_name) }

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
    let(:options) { { limit: 4, default: nil, null: true } }

    it 'calls #add_column in the migration' do
      expect(migration).to(
        have_received(:add_column)
        .with(table_name, column_name, type, options)
      )
    end

    context 'when MEDIUMINT is specified' do
      let(:definition) { 'MEDIUMINT(11) NOT NULL DEFAULT 0' }
      let(:options) { { limit: 3, default: 0, null: false } }

      it 'calls #add_column in the migration' do
        expect(migration).to(
          have_received(:add_column)
          .with(table_name, column_name, type, options)
        )
      end
    end
  end

  context 'with :float' do
    let(:definition) { 'FLOAT' }
    let(:column_name) { :amount }
    let(:type) { :float }
    let(:options) { { limit: nil, default: nil, null: true } }

    it 'calls #add_column in the migration' do
      expect(migration).to(
        have_received(:add_column)
        .with(table_name, column_name, type, options)
      )
    end

    context 'when specifying DEFAULT' do
      let(:definition) { 'FLOAT DEFAULT 0' }
      let(:options) { { limit: nil, default: 0.0, null: true } }

      it 'calls #add_column in the migration' do
        expect(migration).to(
          have_received(:add_column)
          .with(table_name, column_name, type, options)
        )
      end
    end
  end

  context 'with :string' do
    let(:definition) { 'VARCHAR(255)' }
    let(:column_name) { :body }
    let(:type) { :string }
    let(:options) { { limit: 255, default: nil, null: true } }

    it 'calls #add_column in the migration' do
      expect(migration).to(
        have_received(:add_column)
        .with(table_name, column_name, type, options)
      )
    end

    context 'when a default value is specified' do
      let(:definition) { "VARCHAR(255) DEFAULT 'foo'" }
      let(:options) { { limit: 255, default: 'foo', null: true } }

      it 'calls #add_column in the migration' do
        expect(migration).to(
          have_received(:add_column)
          .with(table_name, column_name, type, options)
        )
      end
    end
  end

  context 'with :text' do
    let(:definition) { 'TEXT' }
    let(:column_name) { :body }
    let(:type) { :text }
    let(:options) { { limit: nil, default: nil, null: true } }

    it 'calls #add_column in the migration' do
      expect(migration).to(
        have_received(:add_column)
        .with(table_name, column_name, type, options)
      )
    end
  end

  context 'with :date' do
    let(:definition) { 'DATE DEFAULT NULL' }
    let(:column_name) { :due_on }
    let(:type) { :date }
    let(:options) { { limit: nil, default: nil, null: true } }

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
    let(:options) { { limit: nil, default: nil, null: true } }

    it 'calls #add_column in the migration' do
      expect(migration).to(
        have_received(:add_column)
        .with(table_name, column_name, type, options)
      )
    end
  end

  context 'with :time' do
    let(:definition) { 'TIME' }
    let(:column_name) { :at }
    let(:type) { :time }
    let(:options) { { limit: nil, default: nil, null: true } }

    it 'calls #add_column in the migration' do
      expect(migration).to(
        have_received(:add_column)
        .with(table_name, column_name, type, options)
      )
    end

    context 'when specifying DEFAULT' do
      let(:definition) { 'TIME DEFAULT 12:00:00' }
      let(:options) do
        {
          limit: nil,
          default: Time.parse('2000-01-01 12:00:00'),
          null: true
        }
      end

      it 'calls #add_column in the migration' do
        expect(migration).to(
          have_received(:add_column)
          .with(table_name, column_name, type, options)
        )
      end
    end
  end

  context 'with :timestamp' do
    let(:definition) { 'TIMESTAMP' }
    let(:column_name) { :at }
    let(:type) { :timestamp }
    let(:options) { { limit: nil, default: nil, null: true } }

    it 'calls #add_column in the migration' do
      expect(migration).to(
        have_received(:add_column)
        .with(table_name, column_name, type, options)
      )
    end

    context 'when specifying DEFAULT' do
      let(:definition) { "TIMESTAMP DEFAULT '2016-02-23 15:16:00'" }
      let(:options) do
        {
          limit: nil,
          default: Time.parse('2016-02-23 15:16:00'),
          null: true
        }
      end

      it 'calls #add_column in the migration' do
        expect(migration).to(
          have_received(:add_column)
          .with(table_name, column_name, type, options)
        )
      end
    end
  end

  context 'with :binary' do
    let(:definition) { 'BINARY' }
    let(:column_name) { :binary_data }
    let(:type) { :binary }
    let(:options) { { limit: nil, default: nil, null: true } }

    it 'calls #add_column in the migration' do
      expect(migration).to(
        have_received(:add_column)
        .with(table_name, column_name, type, options)
      )
    end

    context 'when specifying DEFAULT' do
      let(:definition) { "BINARY DEFAULT 'a'" }
      let(:options) { { limit: nil, default: 'a', null: true } }

      it 'calls #add_column in the migration' do
        expect(migration).to(
          have_received(:add_column)
          .with(table_name, column_name, type, options)
        )
      end
    end
  end

  context 'with :boolean' do
    let(:column_name) { :deleted }
    let(:type) { :boolean }

    context 'when specifying BOOLEAN' do
      context 'with NOT NULL' do
        let(:definition) { 'BOOLEAN NOT NULL DEFAULT FALSE' }
        let(:options) { { limit: nil, default: false, null: false } }

        it 'calls #add_column in the migration' do
          expect(migration).to(
            have_received(:add_column)
            .with(table_name, column_name, type, options)
          )
        end
      end

      context 'with NULL' do
        let(:definition) { 'BOOLEAN NULL DEFAULT FALSE' }
        let(:options) { { limit: nil, default: false, null: true } }

        it 'calls #add_column in the migration' do
          expect(migration).to(
            have_received(:add_column)
            .with(table_name, column_name, type, options)
          )
        end
      end
    end

    context 'when specifying TINYINT' do
      context 'with DEFAULT 0' do
        let(:definition) { 'TINYINT(1) default 0' }
        let(:options) { { limit: 1, default: false, null: true } }

        it 'calls #add_column in the migration' do
          expect(migration).to(
            have_received(:add_column)
            .with(table_name, column_name, type, options)
          )
        end
      end

      context 'with DEFAULT 1' do
        let(:definition) { 'TINYINT(1) default 1' }
        let(:options) { { limit: 1, default: true, null: true } }

        it 'calls #add_column in the migration' do
          expect(migration).to(
            have_received(:add_column)
            .with(table_name, column_name, type, options)
          )
        end
      end
    end
  end
end
