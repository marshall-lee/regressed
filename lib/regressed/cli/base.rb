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

        0
      rescue StandardError, SyntaxError => e
        $stderr.puts e.message
        $stderr.puts e.backtrace
        return 1
      end

      private

      def collect
        env = { 'REGRESSED_COLLECT' => '1' }
        system env, collect_command
      end

      def run_changed
        coverage = Regressed::Prediction::RSpec.load_json_dump '.regressed-rspec.json',
                                                               Rugged::Repository.new('.')
        parameters = coverage.entries.map(&:command_line_parameter).join(' ')

        system "#{coverage.command} #{parameters}"
      end
    end
  end
end
