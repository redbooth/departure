require 'spec_helper'

describe PerconaMigrator::AlterArgument do
  let(:alter_argument) { described_class.new(statement) }

  describe '#to_s' do
    subject { alter_argument.to_s }

    context 'when no ALTER TABLE is present' do
      let(:statement) { 'ADD INDEX dummy_index (some_id_field)' }
      it { is_expected.to eq('--alter "ADD INDEX dummy_index (some_id_field)"') }
    end

    context 'when there is an ALTER TABLE present' do
      let(:statement) do
        'ALTER TABLE `comments` CHANGE `some_id` `some_id` INT(11) DEFAULT NULL'
      end
      it { is_expected.to eq('--alter "CHANGE \`some_id\` \`some_id\` INT(11) DEFAULT NULL"') }
    end
  end

  describe '#table_name' do
    subject { alter_argument.table_name }

    let(:statement) do
      'ALTER TABLE `comments` CHANGE `some_id` `some_id` INT(11) DEFAULT NULL'
    end

    it { is_expected.to eq('comments') }

    context 'when the statement is invalid' do
      let(:statement) { 'CREATE TABLE `things`' }

      it 'raises a StandardError' do
        expect { alter_argument.table_name }.to raise_error(StandardError)
      end
    end
  end
end
