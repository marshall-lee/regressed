require 'spec_helper'

describe Regressed::Prediction::Minitest do
  describe '#cmd method' do
    let(:entry) {
      described_class.new 'file' => './spec/lol_test.rb', 'line' => 123
    }

    it "returns something runnable" do
      expect(entry.cmd).to eq('rake test ./spec/lol_test.rb')
    end
  end
end
