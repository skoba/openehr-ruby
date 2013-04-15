require 'openehr/rm/support'
require 'openehr/rm/data_types'
require 'openehr/rm/common'
require 'openehr/rm/composition'
require 'openehr/rm/data_structures'
require 'openehr/rm/demographic'
require 'openehr/rm/security'
require 'openehr/rm/ehr'
require 'openehr/rm/integration'
require 'openehr/rm/factory'

module OpenEHR
  module RM
    include Support
    include DataTypes
    include Common
    include Composition
    include DataStructures
    include Demographic
    include Security
    include EHR
    include Integration
  end
end
