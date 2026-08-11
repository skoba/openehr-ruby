require "bundler/gem_tasks"

require 'rspec/core'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RuboCop::RakeTask.new

namespace :charset do
  desc 'Regenerate lib/openehr/rm/data_types/charset.lst from a local IANA character-sets file (see tasks/support/charset_extract.rb)'
  task :extract do
    ruby 'tasks/support/charset_extract.rb'
  end
end

task :default => :spec
