module Regressed
  class Prediction
    class Minitest < Base
      def cmd
        "rake test #{info['file']}"
      end
    end
  end
end
