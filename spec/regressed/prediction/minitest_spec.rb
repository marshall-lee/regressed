require 'spec_helper'

describe Regressed::Prediction::Minitest do
  describe Regressed::Prediction::Minitest::Entry do
    describe '#command_line_parameter method' do
      let(:entry) {
        described_class.new 'file' => './spec/lol_test.rb', 'line' => 123
      }

      it 'returns command-line parameter for particular test' do
        expect(entry.command_line_parameter).to eq('./spec/lol_test.rb')
      end
    end
  end
end
