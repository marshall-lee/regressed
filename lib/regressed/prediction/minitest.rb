module Regressed
  module Prediction
    class Minitest < Base
      class Entry < Base::Entry
        def command_line_parameter
          info['file']
        end
      end

      def command
        'rake test'
      end

      def entry_class
        Minitest::Entry
      end
    end
  end
end
