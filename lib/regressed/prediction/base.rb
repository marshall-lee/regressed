module Regressed
  class Prediction
    class Base
      attr_reader :info

      def initialize(info)
        @info = info
      end

      def cmd
        raise NotImplementedError
      end
    end
  end
end
