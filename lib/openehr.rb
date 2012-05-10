$:.unshift(File.dirname(__FILE__))

module OpenEHR
  autoload :AssumedLibraryTypes, 'openehr/assumed_library_types'
  autoload :RM, 'openehr/rm'
  autoload :AM, 'openehr/am'
  autoload :Terminology, 'openehr/terminology'
  autoload :Serializer, 'openehr/serializer'
  autoload :Parser, 'openehr/parser'
end
