module Regressed
  module Prediction
    class RSpec < Base
      class Entry < Base::Entry
        def command_line_parameter
          "#{info['spec']}:#{info['line']}"
        end

        def full
          info['full']
        end
      end

      def entry_class
        RSpec::Entry
      end

      def command
        'rspec'
      end
    end
  end
end
