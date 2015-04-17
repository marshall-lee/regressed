require 'bundler/setup'
require 'minitest/autorun'
require 'regressed/minitest'
require 'whatever'

describe Whatever do
  before :each do
    @thing = Whatever.new
  end

  it 'bars' do
    @thing.bar
  end

  it 'bars again' do
    @thing.bar
  end

  it 'baz' do
    @thing.baz
  end
end

