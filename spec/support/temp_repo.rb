require 'fileutils'
require 'rugged'

RSpec.configure do |c|
  c.add_setting :temp_repo_dir, default: File.join('.', 'tmp', 'git')
end

module TempRepo
  def tmp_dir
    File.expand_path(RSpec.configuration.temp_repo_dir)
  end

  def clear_tmp_dir!
    FileUtils.rmtree File.join(tmp_dir, '.')
  end

  attr_reader :repo_path

  def user_name
    'Alan Turing'
  end

  def user_email
    'alan@bletchey.park'
  end

  def author
    {
      email: user_email,
      name: user_name,
      time: Time.now
    }
  end

  def write_fixture(fixture, path=fixture, **options)
    fixture_path = File.join(File.dirname(__FILE__), 'fixtures', *fixture)
    fixture_contents = File.read fixture_path
    write_file(File.join(*path), fixture_contents, options)
  end

  def write_fixture_subdir(subdir, to='.', commit: true)
    fixture_path = File.join(File.dirname(__FILE__), 'fixtures', *subdir)
    FileUtils.cp_r File.join(fixture_path, '.'), File.join(repo_path, to)
    if commit
      add_all_to_stage
      commit("add #{File.join(*subdir)}")
    end
  end

  def head_oid
    @repo.head.target.oid
  end

  def add_to_stage(path)
    index = @repo.index
    index.add path
    index.write
    @tree = index.write_tree
  end

  def add_all_to_stage
    index = @repo.index
    index.add_all
    index.write
    @tree = index.write_tree
  end

  def commit(message)
    Rugged::Commit.create @repo, tree: @tree,
                                 author: author,
                                 message: message,
                                 parents: @repo.empty? ? [] : [@repo.head.target].compact,
                                 update_ref: 'HEAD'
  end

  def commit_file(path)
    full_path = File.join(repo_path, path)
    new_file = !File.exist?(full_path)
    add_to_stage(path)
    commit(new_file ? "add #{path}" : "update #{path}")
  end

  def write_file(path, contents, commit: true)
    full_path = File.join(repo_path, path)
    File.write full_path, contents
    commit_file path if commit
  end

  def create_branch(name, checkout: true)
    @repo.branches.create name, @repo.head.target.oid
    checkout_branch name if checkout
  end

  def checkout_branch(name)
    @repo.checkout name
  end

  def undo_changes!
    @repo.reset @repo.head.target, :hard
  end

  def create_repo(name)
    @repo_path = File.join tmp_dir, name

    destroy_repo
    FileUtils.mkdir_p repo_path
    Rugged::Repository.init_at repo_path

    @repo = Rugged::Repository.new(repo_path)
    @repo.config['user.name'] = user_name
    @repo.config['user.email'] = user_email
    if block_given?
      yield
      destroy_repo
    end
  end

  def destroy_repo(name=nil)
    FileUtils.rmtree (name ? File.join(tmp_dir, name) : repo_path)
  end

  def execute(cmd, env={})
    Bundler.with_clean_env do
      env.merge! 'BUNDLE_GEMFILE' => File.join(repo_path, 'Gemfile')
      system env, cmd, chdir: repo_path
    end
  end
end
