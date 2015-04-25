module Regressed
  module Prediction
    class Base
      class Entry
        attr_reader :info

        def initialize(info)
          @info = info
        end

        def cmd
          raise NotImplementedError
        end
      end

      def initialize(raw_data, repo)
        @raw_data = raw_data
        @repo = repo

        build_cov_map!
        build_affected!
      end

      def self.load_json_dump(file, repo)
        text = if file.kind_of? IO
                 file.read
               else
                 File.read(file)
               end
        raw_data = JSON.parse text
        new(raw_data, repo)
      end

      def entry_class
        raise NotImplementedError
      end

      def entries
        infos = affected.flat_map do |path, line|
          cov_map[File.expand_path(path, repo.workdir)][line].to_a
        end
        infos.uniq!

        infos.map(&entry_class.method(:new))
      end

      private

      attr_reader :raw_data, :repo

      def oid
        raw_data['oid']
      end

      def cov_map
        @cov_map ||= Hash.new do |cov_map, path|
          cov_map[path] = Hash.new do |file_map, line|
            file_map[line] = Set.new
          end
        end
      end

      def affected
        @affected ||= Set.new
      end

      def build_cov_map!
        raw_data['records'].each do |record|
          info = record['info']

          record['files'].each do |path, lines|
            file_map = cov_map[path]

            lines.each do |lineno|
              file_map[lineno + 1] << info
            end
          end
        end
      end

      def build_affected!
        repo.diff_workdir(oid).each_patch do |patch|
          path = patch.delta.old_file[:path]

          patch.each_hunk do |hunk|
            additions = []
            deletions = []
            untouched = {}

            hunk.each_line do |line|
              case line.line_origin
              when :addition then additions << line
              when :deletion then deletions << line
              when :context  then untouched[line.new_lineno] = line
              end
            end

            additions.each do |line|
              before_line = untouched[line.new_lineno - 1]
              after_line = untouched[line.new_lineno + 1]
              affected << [path, before_line.old_lineno] if before_line
              affected << [path, after_line.old_lineno] if after_line
            end

            deletions.each do |line|
              affected << [path, line.old_lineno]
            end
          end
        end
      end
    end
  end
end
