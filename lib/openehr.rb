$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'openehr/version'
require 'openehr/assumed_library_types'
require 'openehr/rm'
require 'openehr/am'
require 'openehr/parser'
require 'openehr/serializer'

# module OpenEHR
#   include AssumedLibraryTypes
#   include RM
#   include AM
#   include Parser
#   include Serializer
# end
