require 'spec_helper'

describe PerconaMigrator::Logger do
  let(:logger) { described_class.new }

  describe '#say' do
    let(:message) { 'a random message' }

    context 'when the subitem options is not specified' do
      it 'prints the message to the stdout' do
        expect(logger).to receive(:puts).with("-- #{message}")
        logger.say(message)
      end
    end

    context 'when the subitem option is specified as false' do
      it 'prints the message to the stdout' do
        expect(logger).to receive(:puts).with("-- #{message}")
        logger.say(message, false)
      end
    end

    context 'when the subitem option is specified as true' do
      it 'prints the message to the stdout' do
        expect(logger).to receive(:puts).with("   -> #{message}")
        logger.say(message, true)
      end
    end
  end

  describe '#write' do
    let(:text) { 'a text' }

    it 'prints the text to the stdout' do
      expect(logger).to receive(:puts).with(text)
      logger.write(text)
    end
  end
end
