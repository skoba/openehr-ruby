$:.unshift(File.dirname(__FILE__))
require 'openehr/version'

module OpenEHR
  require 'openehr/assumed_library_types'
  require 'openehr/rm'
  require 'openehr/am'
  require 'openehr/parser'
  require 'openehr/serializer'
end
