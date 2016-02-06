require 'spec_helper'

describe Regressed::Prediction::RSpec do
  describe Regressed::Prediction::RSpec::Entry do
    describe '#command_line_parameter method' do
      let(:entry) {
        described_class.new 'spec' => './spec/lol_spec.rb', 'line' => 123
      }

      it 'returns command-line parameter for particular test' do
        expect(entry.command_line_parameter).to eq('./spec/lol_spec.rb:123')
      end
    end
  end
end
