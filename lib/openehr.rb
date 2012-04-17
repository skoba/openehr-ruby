$:.unshift(File.dirname(__FILE__))

module OpenEHR
  VERSION = '1.0.3'
  autoload :AssumedLibraryTypes, 'openehr/assumed_library_types'
  autoload :RM, 'openehr/rm'
  autoload :AM, 'openehr/am'
  autoload :Terminology, 'openehr/terminology'
  autoload :Serializer, 'openehr/serializer'
  autoload :Parser, 'openehr/parser'
end
