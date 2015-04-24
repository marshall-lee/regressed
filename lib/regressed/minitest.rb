require 'regressed'
require 'regressed/collection/minitest'
require 'regressed/prediction/minitest'

if ENV['COLLECTION']
  repo = Rugged::Repository.new('.')
  Regressed::Collection::Minitest.new(repo)
end
