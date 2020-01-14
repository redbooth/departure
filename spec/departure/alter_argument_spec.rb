require 'spec_helper'

describe Departure::AlterArgument do
  let(:alter_argument) { described_class.new(statement) }

  describe '#initialize' do
    subject { described_class.new(statement) }

    context 'when the statement is invalid' do
      let(:statement) { 'CREATE TABLE `things`' }

      it 'raises a InvalidAlterStatement' do
        expect { described_class.new(statement) }.to(
          raise_error(Departure::InvalidAlterStatement)
        )
      end
    end
  end

  describe '#to_s' do
    subject { alter_argument.to_s }

    context 'when there is an ALTER TABLE present' do
      let(:statement) do
        print(:statement)
        'ALTER TABLE `comments` CHANGE `some_id` `some_id` INT(11) DEFAULT NULL'
      end

      it do
        is_expected.to(
          eq('--alter "CHANGE \`some_id\` \`some_id\` INT(11) DEFAULT NULL"')
        )
      end
    end

    context 'when there is an ALTER TABLE, with one line feed, present' do
      let(:statement) do
        print(:statement)
        'ALTER TABLE comments\n CHANGE `some_id` `some_id` INT(11) DEFAULT NULL'
      end

      it do
        is_expected.to(
          eq('--alter "CHANGE \`some_id\` \`some_id\` INT(11) DEFAULT NULL"')
        )
      end
    end

    context 'when there is an ALTER TABLE, several with line feeds, present and grave marks' do
      let(:statement) do
        print(:statement)
        'ALTER TABLE `comments`\n CHANGE\n `some_id` `some_id`\n INT(11) DEFAULT NULL'
      end

      it do
        is_expected.to(
          eq('--alter "CHANGE \`some_id\` \`some_id\` INT(11) DEFAULT NULL"')
        )
      end
    end

  end

  context "when there ARE grave marks wrapping the table name" do
    describe '#table_name' do
      subject { alter_argument.table_name }

      let(:statement) do
        'ALTER TABLE `comments` CHANGE `some_id` `some_id` INT(11) DEFAULT NULL'
      end
      it { is_expected.to eq('comments') }
    end
  end

  context "when there ARE NO grave marks wrapping the table name" do
    describe '#table_name' do
      subject { alter_argument.table_name }

      let(:statement) do
        'ALTER TABLE foo CHANGE `some_id` `some_id` INT(11) DEFAULT NULL'
      end
      it { is_expected.to eq('foo') }
    end
  end
end
