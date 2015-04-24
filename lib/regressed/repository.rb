require 'rugged'

module Regressed
  class Repository
    def initialize(git)
      @git = git
    end

    attr_reader :git

    def head
      git.head.target
    end

    def head_oid
      head.oid
    end

    def changed_since?(diffable=head)
      git.diff_workdir(diffable).stat[0] == 0
    end
  end
end
