$:.unshift(File.dirname(__FILE__))
require 'am/archetype'
require 'am/openehr_profile'

module OpenEHR
  module AM
    include Archtype
    include OpenEHRProfile
  end
end
