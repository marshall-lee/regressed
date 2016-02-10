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
      let!(:exit_status) do
        execute "bundle exec #{command} --collect > /dev/null"
      end

      it 'exits with status 0' do
        expect(exit_status).to be true
      end

      it 'creates coverage file' do
        expect(JSON.parse(File.read(coverage_file_path))).to be_truthy
      end

      describe 'when ran again' do
        let!(:content) do
          execute_capturing_output "bundle exec #{command} 2> /dev/null"
        end

        it 'does nothing' do
          expect(content).not_to include('examples')
        end
      end

      describe 'when ran with --tests' do
        let!(:content) do
          execute_capturing_output "bundle exec #{command} --tests 2> /dev/null"
        end

        it 'displays empty result' do
          expect(content.strip).to be_empty
        end
      end

      describe 'then appending a line to bar' do
        before do
          insert_line 'lib/whatever.rb', 8, '    fail' # append to method `bar`
        end

        describe 'then ran again' do
          describe 'without args' do
            let!(:content) { execute_capturing_output "bundle exec #{command}" }

            it 'runs tests for bars and bars_again' do
              expect(content).to include('2 examples, 2 failures')
            end
          end

          describe 'with --tests' do
            let(:content) do
              execute_capturing_output "bundle exec #{command} --tests"
            end

            it 'outputs some test file name' do
              expect(content).to match(/whatever_.*\.rb/)
            end
          end

          describe 'with --collect' do
            let!(:exit_status_2) do
              execute "bundle exec #{command} --collect > /dev/null"
            end

            it 'exits with status 0' do
              expect(exit_status_2).to be true
            end

            describe 'then ran again without arguments' do
              let!(:exit_status_3) do
                execute "bundle exec #{command} > /dev/null"
              end

              it 'exits with status 0' do
                expect(exit_status_3).to be true
              end
            end
          end
        end
      end

      context 'after changing git head' do
        before do
          write_file 'commit_me', 'test'
          commit_file 'commit_me'
        end

        describe 'when ran again without --collect' do
          it 'fails' do
            exit_status = execute "bundle exec #{command} 2> /dev/null"
            expect(exit_status).to be false
          end
        end
      end
    end

    context 'on fresh dir without coverage file' do
      describe 'when ran without arguments' do
        let!(:exit_status) { execute "bundle exec #{command} 2> /dev/null" }

        it 'fails' do
          expect(exit_status).to be false
        end
      end

      describe 'when ran with --tests' do
        let!(:exit_status) do
          execute "bundle exec #{command} --tests 2> /dev/null"
        end

        it 'fails' do
          expect(exit_status).to be false
        end
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
