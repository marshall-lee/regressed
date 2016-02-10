module Regressed
  module CLI
    class Minitest < Base
      private

      def collect_command
        'rake test'
      end
    end
  end
end
