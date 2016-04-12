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

    context 'when verbose is true' do
      let(:logger) { described_class.new(verbose: true) }

      it 'enables the output to the stdout' do
        expect(logger).to receive(:puts).with(/random message/)
        logger.say('random message')
      end
    end

    context 'when verbose is false' do
      let(:logger) { described_class.new(verbose: false) }

      it 'disables the output to the stdout' do
        expect(logger).not_to receive(:puts).with(/random message/)
        logger.say('random message')
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
