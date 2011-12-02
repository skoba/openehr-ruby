$:.unshift(File.dirname(__FILE__))

module OpenEHR
  VERSION = '0.9.5'
  autoload :AssumedLibraryTypes, 'open_ehr/assumed_library_types'
  autoload :RM, 'open_ehr/rm'
  autoload :AM, 'open_ehr/am'
  autoload :Terminology, 'open_ehr/terminology'
  autoload :Serializer, 'open_ehr/serializer'
  autoload :Parser, 'open_ehr/parser'
end
