module Regressed
  module CLI
    class Base
      def run(args = ARGV)
        puts 'Hello world!'
        0
      rescue StandardError, SyntaxError => e
        $stderr.puts e.message
        $stderr.puts e.backtrace
        return 1
      end
    end
  end
end
