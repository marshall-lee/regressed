require 'regressed'
require 'regressed/collection/rspec'
require 'regressed/prediction/rspec'

Regressed::Collection::RSpec.new if ENV['COLLECTION']
