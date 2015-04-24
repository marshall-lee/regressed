module Regressed
  module Prediction
    class RSpec < Base
      class Entry < Base::Entry
        def cmd
          "rspec #{info['spec']}:#{info['line']}"
        end

        def full
          info['full']
        end
      end

      def entry_class
        RSpec::Entry
      end
    end
  end
end
