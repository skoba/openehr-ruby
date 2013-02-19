$:.unshift(File.dirname(__FILE__))
require 'openehr/version'

module OpenEHR
  autoload :AssumedLibraryTypes, 'openehr/assumed_library_types'
  autoload :RM, 'openehr/rm'
  autoload :AM, 'openehr/am'
  autoload :Parser, 'openehr/parser'
  autoload :Serializer, 'openehr/serializer'
  autoload :Terminology, 'openehr/terminology'
end
