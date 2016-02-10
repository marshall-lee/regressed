require 'optparse'
require 'regressed/prediction'
require 'regressed/prediction/rspec'

module Regressed
  module CLI
    class Base

      # FIXME: needs refactoring

      def run(args = ARGV)
        options = {}
        OptionParser.new do |opts|
          opts.on '--collect' do
            options[:collect] = true
          end
          opts.on '--tests' do
            options[:tests] = true
          end
        end.parse!

        if options[:collect]
          collect
        elsif options[:tests]
          show_changed_tests
        else
          run_changed_tests
        end
      rescue StandardError, SyntaxError => e
        $stderr.puts e.message
        $stderr.puts e.backtrace
        return 1
      end

      private

      def collect
        env = { 'REGRESSED_COLLECT' => '1' }
        system env, collect_command
        0
      end

      def run_changed_tests
        on_coverage do |coverage|
          parameters = coverage.entries.map(&:command_line_parameter).join(' ')
          system "#{coverage.command} #{parameters}"
          $?.exitstatus
        end
      end

      def show_changed_tests
        on_coverage do |coverage|
          puts 'Affected tests:'
          coverage.entries.map(&:command_line_parameter).each do |t|
            puts t
          end
        end
      end

      # Get coverage data and run block with it or print error and return exit
      # status
      def on_coverage
        repository = Rugged::Repository.new('.')

        # FIXME: filename should be different for different test frameworks
        unless File.exist? '.regressed-rspec.json'
          STDERR.puts 'Coverage data not generated. Run with --collect.'
          return 1
        end

        coverage = Regressed::Prediction::RSpec.load_json_dump '.regressed-rspec.json',
                                                               repository

        if coverage.oid != repository.head.target.oid
          STDERR.puts "Coverage data was generated for commit " \
                      "#{coverage.oid}, but current HEAD is " \
                      "#{repository.head.target.oid}. Please rerun all tests" \
                      " (--collect)"
          return 1
        end

        # TODO: move to Regressed::Prediction::Base
        entries = coverage.entries
        if entries.empty?
          STDERR.puts 'No changes affecting tests'
        else
          yield coverage
        end
        0
      end
    end
  end
end
