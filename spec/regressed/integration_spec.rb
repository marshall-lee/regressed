require 'spec_helper'

describe 'Integration with test frameworks' do
  include_context 'test repository'

  shared_examples 'foo baz project' do
    describe 'when nothing is changed' do
      it 'predicts nothing' do
        expect(prediction.entries).to be_empty
      end
    end

    describe 'when appending a line to bar' do
      before do
        insert_line 'lib/whatever.rb', 8, '    fail' # append to method `bar`
      end

      it 'predicts bars specs' do
        expect(prediction.entries.map(&:info)).to contain_exactly(
          whatever_bars,
          whatever_bars_again
        )
      end

      describe 'and one more line to baz' do
        before do
          insert_line 'lib/whatever.rb', 12, '    lol' # prepend to method `baz`
        end

        it 'predicts all specs' do
          expect(prediction.entries.map(&:info)).to contain_exactly(
            whatever_bars,
            whatever_bars_again,
            whatever_baz
          )
        end
      end
    end

    describe 'when deleting a line' do
      context 'in bars' do
        before do
          delete_line 'lib/whatever.rb', 7
        end

        it 'predicts bars specs' do
          expect(prediction.entries.map(&:info)).to contain_exactly(
            whatever_bars,
            whatever_bars_again
          )
        end
      end

      context 'in baz' do
        before do
          delete_line 'lib/whatever.rb', 11
        end

        it 'predicts baz specs' do
          expect(prediction.entries.map(&:info)).to contain_exactly(
            whatever_baz
          )
        end
      end
    end

    describe 'when changing a line' do
      context 'in bars' do
        before do
          change_line 'lib/whatever.rb', 7, '    fail'
        end

        it 'predicts bars specs' do
          expect(prediction.entries.map(&:info)).to contain_exactly(
            whatever_bars,
            whatever_bars_again
          )
        end
      end

      context 'in baz' do
        before do
          change_line 'lib/whatever.rb', 11, '    wat'
        end

        it 'predicts baz specs' do
          expect(prediction.entries.map(&:info)).to contain_exactly(
            whatever_baz
          )
        end
      end
    end
  end

  describe 'with RSpec' do
    before(:all) do
      execute 'bundle exec rspec > /dev/null', 'REGRESSED_COLLECT' => '1'
    end

    let(:prediction) do
      Regressed::Prediction::RSpec.load_json_dump File.join(repo.workdir, '.regressed-rspec.json'),
                                                  repo
    end


    let(:whatever_bars) {
      a_hash_including 'full' => 'Whatever bars'
    }

    let(:whatever_bars_again) {
      a_hash_including 'full' => 'Whatever bars again'
    }

    let(:whatever_baz) {
      a_hash_including 'full' => 'Whatever baz'
    }

    include_examples 'foo baz project'
  end

  describe 'with Minitest' do
    before(:all) do
      execute 'ruby -I lib spec/whatever_test.rb > /dev/null', 'REGRESSED_COLLECT' => '1'
    end

    let(:prediction) do
      Regressed::Prediction::Minitest.load_json_dump File.join(repo.workdir, '.regressed-minitest.json'),
                                                     repo
    end

    let(:whatever_bars) {
      a_hash_including 'desc' => 'Whatever', 'name' => 'test_0001_bars'
    }

    let(:whatever_bars_again) {
      a_hash_including 'desc' => 'Whatever', 'name' => 'test_0002_bars again'
    }

    let(:whatever_baz) {
      a_hash_including 'desc' => 'Whatever', 'name' => 'test_0003_baz'
    }

    include_examples 'foo baz project'
  end
end
