require 'regressed'
require 'regressed/collection/minitest'
require 'regressed/prediction/minitest'

Regressed::Collection::Minitest.new if ENV['COLLECTION']
