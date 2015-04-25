require 'regressed'
require 'regressed/collection'
require 'regressed/collection/minitest'

if ENV['COLLECTION']
  repo = Rugged::Repository.new('.')
  Regressed::Collection::Minitest.new(repo)
end
