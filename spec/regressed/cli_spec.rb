require 'spec_helper'

describe 'CLI' do
  include_context 'test repository'

  after(:example) do
    # other tests use coverage files persisting between examples
    remove_coverage_files
  end

  let(:coverage_file_path) do
    File.join(repo.workdir, coverage_filename)
  end

  shared_examples 'foo baz project' do
    context 'when first ran with --collect' do
      before do
        exit_status = execute "bundle exec #{command} --collect > /dev/null"
        expect(exit_status).to be true
      end

      it 'creates coverage file' do
        expect(JSON.parse(File.read(coverage_file_path))).to be_truthy
      end

      describe 'when ran again' do
        let(:content) do
          execute_capturing_output "bundle exec #{command}"
        end

        it 'does nothing' do
          expect(content).to include('0 examples, 0 failures')
        end
      end

      describe 'when ran with --tests' do
        it 'displays empty result'
      end

      describe 'when appending a line to bar' do
        before do
          insert_line 'lib/whatever.rb', 8, '    fail' # append to method `bar`
        end

        it 'runs tests for bars and bars_again' do
          content = execute_capturing_output "bundle exec #{command}"
          expect(content).to include('2 examples, 2 failures')
        end

        describe 'when ran with --tests' do
          it 'displays list of 2 tests: bars and bars_again'
        end
      end

      context 'after changing git head' do
        pending 'change head ref, i.e. by commiting'
        describe 'when ran again without --collect' do
          it 'fails'
        end
      end
    end

    context 'when ran for the first time without --collect' do
      it 'fails' do
        exit_status = execute "bundle exec #{command} > /dev/null"
        expect(exit_status).to be false
      end
    end
  end

  describe 'with RSpec' do
    let(:coverage_filename) { '.regressed-rspec.json' }
    let(:command) { 'regressed-rspec' }

    include_examples 'foo baz project'
  end

  pending 'with Minitest' do
    let(:coverage_filename) { '.regressed-minitest.json' }
    let(:command) { 'regressed-minitest' }

    include_examples 'foo baz project'
  end
end
