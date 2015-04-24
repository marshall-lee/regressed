require 'coverage'
require 'json'

require 'regressed/repository'
require 'regressed/collection/base'

module Regressed
  module Collection
    class Base
      def initialize(git)
        Coverage.start
        @records = []
        @repo = Repository.new(git)
      end

      def sniff_coverage(info)
        before = Coverage.peek_result
        result = yield
        after = Coverage.peek_result
        add info, before, after
        result
      end

      def add(info, before, after)
        files = {}

        after.each do |file_name, line_cov|
          before_line_cov = before[file_name]

          # skip arrays that are exactly the same
          next if before_line_cov == line_cov

          # subtract the old coverage from the new coverage
          cov = line_cov.zip(before_line_cov).map do |line_after, line_before|
            line_after - line_before if line_after
          end

          # determine line numbers that are actually executed
          lines = cov.each_index.select { |i| cov[i] && cov[i] > 0 }

          files[file_name] = lines
        end

        @records << { info: info, files: files }
      end

      def as_json
        {
          oid: repo.head_oid,
          records: @records
        }
      end

      def dump_coverage(file_name=".regressed-#{type}.json")
        File.open(file_name, 'w') do |f|
          f.write JSON.dump(as_json)
        end
      end

      private

      attr_reader :repo
    end
  end
end
