require 'spec_helper'

describe Lhm::Column do
  let(:name) { :some_field_name }
  let(:column) { described_class.new(name, definition) }

  describe '#type' do
    subject { column.type }

    context 'when defining INT' do
      let(:definition) { 'INT' }
      it { is_expected.to eq(:integer) }
    end

    context 'when defining MEDIUMINT' do
      let(:definition) { 'MEDIUMINT' }
      it { is_expected.to eq(:integer) }
    end

    context 'when defining TINYINT' do
      let(:definition) { 'TINYINT' }
      it { is_expected.to eq(:integer) }
    end

    context 'when defining FLOAT' do
      let(:definition) { 'FLOAT' }
      it { is_expected.to eq(:float) }
    end

    context 'when defining VARCHAR' do
      let(:definition) { 'VARCHAR' }
      it { is_expected.to eq(:string) }
    end

    context 'when defining TEXT' do
      let(:definition) { 'TEXT' }
      it { is_expected.to eq(:text) }
    end

    context 'when defining DATE' do
      let(:definition) { 'DATE' }
      it { is_expected.to eq(:date) }
    end

    context 'when defining DATETIME' do
      let(:definition) { 'DATETIME' }
      it { is_expected.to eq(:datetime) }
    end

    context 'when defining TIMESTAMP' do
      let(:definition) { 'TIMESTAMP' }
      it { is_expected.to eq(:timestamp) }
    end

    context 'when defining BINARY' do
      let(:definition) { 'BINARY' }
      it { is_expected.to eq(:binary) }
    end

    context 'when defining BOOLEAN' do
      let(:definition) { 'BOOLEAN' }
      it { is_expected.to eq(:boolean) }
    end
  end

  describe '#to_hash' do
    subject { column.to_hash }

    context 'when defining INT' do
      let(:definition) { 'INT' }

      its([:limit]) { is_expected.to eq(4)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with DEFAULT' do
        let(:definition) { 'INT DEFAULT NULL' }
        its([:default]) { is_expected.to eq(nil)  }
      end

      context 'with NOT NULL' do
        let(:definition) { 'INT NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end

      context 'with limit' do
        let(:definition) { 'INT(11)' }
        its([:limit]) { is_expected.to eq(4)  }
      end
    end

    context 'when defining MEDIUMINT' do
      let(:definition) { 'MEDIUMINT' }

      its([:limit]) { is_expected.to eq(3)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with DEFAULT' do
        let(:definition) { 'MEDIUMINT DEFAULT 0' }
        its([:default]) { is_expected.to eq(0)  }
      end

      context 'with NOT NULL' do
        let(:definition) { 'MEDIUMINT NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end

      context 'with limit' do
        let(:definition) { 'MEDIUMINT(11)' }
        its([:limit]) { is_expected.to eq(3)  }
      end
    end

    context 'when defining TINYINT' do
      let(:definition) { 'TINYINT' }

      its([:limit]) { is_expected.to eq(1)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with DEFAULT' do
        let(:definition) { 'TINYINT default 0' }
        its([:default]) { is_expected.to eq(0)  }
      end

      context 'with NOT NULL' do
        let(:definition) { 'TINYINT NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end

      context 'with limit' do
        let(:definition) { 'TINYINT(1)' }
        its([:limit]) { is_expected.to eq(1)  }
      end
    end

    # TODO: FLOAT(M, D) ? see:
    # https://dev.mysql.com/doc/refman/5.5/en/floating-point-types.html
    context 'when defining FLOAT' do
      let(:definition) { 'FLOAT' }

      its([:limit]) { is_expected.to eq(nil)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with DEFAULT' do
        let(:definition) { 'FLOAT DEFAULT 0' }
        its([:default]) { is_expected.to eq(0.0)  }
      end

      context 'with NOT NULL' do
        let(:definition) { 'FLOAT NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end
    end

    context 'when defining VARCHAR' do
      let(:definition) { 'VARCHAR' }

      its([:limit]) { is_expected.to eq(nil)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with DEFAULT' do
        let(:definition) { "VARCHAR DEFAULT 'foo'" }
        its([:default]) { is_expected.to eq('foo')  }
      end

      context 'with NOT NULL' do
        let(:definition) { 'VARCHAR NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end

      context 'with limit' do
        let(:definition) { 'VARCHAR(255)' }
        its([:limit]) { is_expected.to eq(255)  }
      end
    end

    context 'when defining TEXT' do
      let(:definition) { 'TEXT' }

      its([:limit]) { is_expected.to eq(nil)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with NOT NULL' do
        let(:definition) { 'TEXT NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end
    end

    context 'when defining DATE' do
      let(:definition) { 'DATE' }

      its([:limit]) { is_expected.to eq(nil)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with DEFAULT' do
        let(:definition) { "DATE DEFAULT NULL" }
        its([:default]) { is_expected.to eq(nil)  }
      end

      context 'with NOT NULL' do
        let(:definition) { 'DATE NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end
    end

    context 'when defining DATETIME' do
      let(:definition) { 'DATETIME' }

      its([:limit]) { is_expected.to eq(nil)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with DEFAULT' do
        let(:definition) { "DATETIME DEFAULT '2016-02-24 13:21:00'" }
        its([:default]) { is_expected.to eq(Time.parse('2016-02-24 13:21:00')) }
      end

      context 'with NOT NULL' do
        let(:definition) { 'DATETIME NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end
    end

    context 'when defining TIMESTAMP' do
      let(:definition) { 'TIMESTAMP' }

      its([:limit]) { is_expected.to eq(nil)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with DEFAULT' do
        let(:definition) { "TIMESTAMP DEFAULT '2016-02-24 13:21:00'" }
        its([:default]) { is_expected.to eq(Time.parse('2016-02-24 13:21:00')) }
      end

      context 'with NOT NULL' do
        let(:definition) { 'TIMESTAMP NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end
    end

    context 'when defining BINARY' do
      let(:definition) { 'BINARY' }

      its([:limit]) { is_expected.to eq(nil)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with DEFAULT' do
        let(:definition) { "BINARY DEFAULT 'a'" }
        its([:default]) { is_expected.to eq('a')  }
      end

      context 'with NOT NULL' do
        let(:definition) { 'BINARY NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end

      context 'with limit' do
        let(:definition) { 'BINARY(3)' }
        its([:limit]) { is_expected.to eq(3)  }
      end
    end

    context 'when defining BOOLEAN' do
      let(:definition) { 'BOOLEAN' }

      its([:limit]) { is_expected.to eq(nil)  }
      its([:default]) { is_expected.to eq(nil)  }
      its([:null]) { is_expected.to eq(true)  }

      context 'with DEFAULT' do
        let(:definition) { 'BOOLEAN DEFAULT FALSE' }
        its([:default]) { is_expected.to eq(false)  }
      end

      context 'with NOT NULL' do
        let(:definition) { 'BOOLEAN NOT NULL' }
        its([:null]) { is_expected.to eq(false)  }
      end
    end
  end
end
