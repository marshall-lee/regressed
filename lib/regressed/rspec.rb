require 'regressed'
require 'regressed/collection/rspec'
require 'regressed/prediction/rspec'

if ENV['COLLECTION']
  repo = Rugged::Repository.new('.')
  Regressed::Collection::RSpec.new(repo)
end
