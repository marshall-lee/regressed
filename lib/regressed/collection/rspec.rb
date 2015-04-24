require 'rspec'

module Regressed
  module Collection
    class RSpec < Base
      def initialize(*)
        super

        ::RSpec.configuration.around(:example, &method(:run_example))
        ::RSpec.configuration.after(:suite, &method(:after_suite))
      end

      def after_suite(context)
        dump_coverage
      end

      def run_example(example)
        info = {
          spec: example.file_path,
          line: example.metadata[:line_number],
          full: example.full_description
        }
        sniff_coverage(info) { example.run }
      end

      def type
        :rspec
      end
    end
  end
end
