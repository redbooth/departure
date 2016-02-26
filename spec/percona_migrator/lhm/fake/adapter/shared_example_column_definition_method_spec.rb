# TODO: What about ENUM?
shared_examples 'column-definition method' do |method_name|
  let(:migration) { double(:migration) }
  let(:table_name) { :comments }

  let(:adapter) { described_class.new(migration, table_name) }
  let(:column) { instance_double(PerconaMigrator::Lhm::Fake::Column) }

  before do
    allow(migration).to(
      receive(method_name).with(table_name, column_name, type, options)
    )
    allow(PerconaMigrator::Lhm::Fake::Column).to(
      receive(:new).and_return(column)
    )
  end

  before do
    allow(column).to receive(:type).and_return(type)
    allow(column).to receive(:to_hash).and_return(options)
  end

  before { adapter.public_send(method_name, column_name, definition) }

  let(:definition) { 'INT(11) DEFAULT NULL' }
  let(:column_name) { :some_id_field }
  let(:type) { :integer }
  let(:options) { { limit: 4, default: nil, null: true } }

  it 'gets the type from the columns' do
    expect(column).to have_received(:type)
  end

  it "calls ##{method_name} in the migration" do
    expect(migration).to(
      have_received(method_name)
      .with(table_name, column_name, type, options)
    )
  end
end
