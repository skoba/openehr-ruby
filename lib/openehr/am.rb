require 'openehr/am/archetype'
require 'openehr/am/openehr_profile'

module OpenEHR
  module AM
    include Archetype
    include OpenEHRProfile
  end
end
