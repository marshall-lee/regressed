require 'optparse'
require 'regressed/prediction'
require 'regressed/prediction/rspec'

module Regressed
  module CLI
    class Base
      def run(args = ARGV)

        options = {}
        OptionParser.new do |opts|
          opts.on '--collect' do
            options[:collect] = true
          end
        end.parse!

        if options[:collect]
          collect
        else
          run_changed
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

      def run_changed
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
          parameters = entries.map(&:command_line_parameter).join(' ')

          system "#{coverage.command} #{parameters}"
        end
        0
      end
    end
  end
end
