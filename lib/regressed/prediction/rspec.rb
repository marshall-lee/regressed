module Regressed
  class Prediction
    class RSpec < Base
      def cmd
        "rspec #{info['spec']}:#{info['line']}"
      end

      def full
        info['full']
      end
    end
  end
end
