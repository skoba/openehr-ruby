require 'rubygems'
require 'tempfile'
require 'tmpdir'
#require 'spork'
require 'simplecov'
require 'rspec'
require 'rspec/expectations'
require 'rspec/collection_matchers'

SimpleCov.start do
  skip '/spec/'
  skip '/vendor/'
  group 'Parser', 'lib/openehr/parser'
  group 'Template', 'lib/openehr/am/template'
  group 'Archetype', 'lib/openehr/am/archetype'
  group 'RM', 'lib/openehr/rm'
  coverage_dir 'coverage'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'openehr'

# Spork.prefork do
#   SimpleCov.start
# end

# Spork.each_run do

# end


