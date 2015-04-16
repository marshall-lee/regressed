require 'bundler/setup'
require 'bundler/gem_tasks'

task :default => :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/regressed_spec.rb,spec/regressed/**/*_spec.rb'
end
