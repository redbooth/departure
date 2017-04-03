require 'spec_helper'

describe PerconaMigrator::LogSanitizers::ConnectionDetailsSanitizer do
  subject { described_class.new(connection_details) }

  let(:password_argument) { '-p secret_password' }
  let(:connection_details) { double(:connection_details, password_argument: password_argument) }

  describe '#execute' do
    let(:text) { "pt-online-tools #{password_argument} execute alter table" }

    it 'filters out password' do
      expect(subject.execute(text)).to include('[filtered_password]')
      expect(subject.execute(text)).to_not include(password_argument)
    end

    context 'when password argument is blank' do
      let(:password_argument) { '' }
      it 'returns text without changes' do
        expect(subject.execute(text)).to eq text
      end
    end
  end
end