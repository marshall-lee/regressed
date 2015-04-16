require 'rugged'
require 'set'

module Regressed
  class Prediction
    Types = [:rspec, :minitest].freeze

    attr_reader :file_path, :type, :repo_path, :repo

    def initialize(file_path, type, repo_path: '.')
      @file_path = file_path
      @type = type
      @repo_path = repo_path

      fail "unknown type `#{type.inspect}`" unless Types.include?(type)

      @repo = Rugged::Repository.new(repo_path)

      build_cov_map!
      build_affected!
    end

    def entries
      infos = affected.flat_map do |path, line|
        cov_map[File.expand_path(path, repo_path)][line].to_a
      end
      infos.uniq!

      infos.map(&entry_class.method(:new))
    end

    private

    def data
      @data ||= JSON.parse File.read file_path
    end

    def oid
      data['oid']
    end

    def cov_map
      @cov_map ||= Hash.new do |hash, file|
        hash[file] = Hash.new do |i, line|
          i[line] = Set.new
        end
      end
    end

    def affected
      @affected ||= Set.new
    end

    def build_cov_map!
      data['records'].each do |hash|
        info = hash['info']

        hash['files'].each do |path, lines|
          file_map = cov_map[path]

          lines.each do |i|
            file_map[i + 1] << info
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

    def entry_class
      case type
      when :rspec then Prediction::RSpec
      when :minitest then Prediction::Minitest
      end
    end

  end
end

require 'regressed/prediction/base'
require 'regressed/prediction/minitest'
require 'regressed/prediction/rspec'
