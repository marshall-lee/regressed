require 'minitest'

module Regressed
  module Collection
    class Minitest < Base
      def initialize
        super

        me = self

        ::Minitest::Runnable.singleton_class.instance_eval do
          extension = Module.new do
            define_method :run_one_method do |*args|
              me.run_one_method(proc { super(*args) }, *args)
            end
          end

          prepend extension
        end

        ::Minitest.after_run do
          dump_coverage
        end
      end

      def run_one_method(orig, klass, method_name, reporter)
        file, line = klass.instance_method(method_name).source_location
        info = {
          file: file,
          line: line,
          desc: klass,
          name: method_name
        }
        sniff_coverage(info, &orig)
      end

      def type
        :minitest
      end
    end
  end
end
