require 'spec_helper'

describe Regressed::Prediction::RSpec do
  describe Regressed::Prediction::RSpec::Entry do
    describe '#cmd method' do
      let(:entry) {
        described_class.new 'spec' => './spec/lol_spec.rb', 'line' => 123
      }

      it "returns something runnable" do
        expect(entry.cmd).to eq('rspec ./spec/lol_spec.rb:123')
      end
    end
  end
end
