require 'openehr/version'
require 'openehr/assumed_library_types'
require 'openehr/rm'
require 'openehr/am'
require 'openehr/parser'
require 'openehr/serializer'

module OpenEHR
  include AssumedLibraryTypes
  include RM
  include AM
  include Parser
  include Serializer
end
