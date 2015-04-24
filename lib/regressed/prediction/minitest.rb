module Regressed
  module Prediction
    class Minitest < Base
      class Entry < Base::Entry
        def cmd
          "rake test #{info['file']}"
        end
      end

      def entry_class
        Minitest::Entry
      end
    end
  end
end
