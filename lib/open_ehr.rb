$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenEHR
  VERSION = '0.6.0'
  autoload :AssumedLibraryTypes, 'open_ehr/assumed_library_types'
  autoload :RM, 'open_ehr/rm'
  autoload :AM, 'open_ehr/am'
  autoload :Terminology, 'open_ehr/terminology'
  autoload :Serializer, 'open_ehr/serializer'
end
