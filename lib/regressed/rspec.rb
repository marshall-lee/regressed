require 'regressed'
require 'regressed/collection'
require 'regressed/collection/rspec'

if ENV['REGRESSED_COLLECT']
  repo = Rugged::Repository.new('.')
  Regressed::Collection::RSpec.new(repo)
end
