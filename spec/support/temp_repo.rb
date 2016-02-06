require 'fileutils'
require 'rugged'

RSpec.configure do |c|
  c.add_setting :temp_repo_dir, default: File.join('.', 'tmp', 'git')
end

RSpec.shared_context 'test repository' do
  before(:all) do
    clear_tmp_dir!
    create_repo 'whatever'
    write_fixture_subdir 'whatever', '.'
    execute 'bundle install > /dev/null'
    commit_file 'Gemfile.lock'
  end

  after(:example) do
    undo_changes!
  end

  after(:all) do
    destroy_repo 'whatever'
  end
end

module TempRepo
  def tmp_dir
    File.expand_path(RSpec.configuration.temp_repo_dir)
  end

  def clear_tmp_dir!
    FileUtils.rmtree File.join(tmp_dir, '.')
  end

  attr_reader :repo

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
    FileUtils.cp_r File.join(fixture_path, '.'), File.join(repo.workdir, to)
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
    full_path = File.join(repo.workdir, path)
    new_file = !File.exist?(full_path)
    add_to_stage(path)
    commit(new_file ? "add #{path}" : "update #{path}")
  end

  def write_file(path, contents, commit: true)
    full_path = File.join(repo.workdir, path)
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

  def remove_coverage_files
    coverage_files = File.join(repo.workdir, '.regressed-*.json')
    Dir.glob(coverage_files) do |file|
      File.unlink(file)
    end
  end

  def create_repo(name)
    repo_workdir = File.join tmp_dir, name

    FileUtils.mkdir_p repo_workdir
    Rugged::Repository.init_at repo_workdir

    @repo = Rugged::Repository.new(repo_workdir)

    @repo.config['user.name'] = user_name
    @repo.config['user.email'] = user_email
    if block_given?
      yield
      destroy_repo
    end
  end

  def destroy_repo(name=nil)
    FileUtils.rmtree (name ? File.join(tmp_dir, name) : repo.workdir)
  end

  def execute(cmd, env={})
    Bundler.with_clean_env do
      env.merge! 'BUNDLE_GEMFILE' => File.join(repo.workdir, 'Gemfile')
      system env, cmd, chdir: repo.workdir
    end
  end

  def execute_capturing_output(cmd, env={})
    Tempfile.create("output") do |f|
      execute "#{cmd} > #{f.path}"
      f.read
    end
  end
end
