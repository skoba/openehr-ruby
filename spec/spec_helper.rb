require 'rubygems'
#require 'spork'
require 'simplecov'
require 'rspec'
require 'rspec/expectations'
require 'rspec/collection_matchers'

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  add_group 'Parser', 'lib/openehr/parser'
  add_group 'Template', 'lib/openehr/am/template'
  add_group 'Archetype', 'lib/openehr/am/archetype'
  add_group 'RM', 'lib/openehr/rm'
  coverage_dir 'coverage'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'openehr'

# Spork.prefork do
#   SimpleCov.start
# end

# Spork.each_run do

# end


