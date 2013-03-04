$:.unshift(File.dirname(__FILE__))

module OpenEHR
  module RM
    require 'rm/support'
    require 'rm/data_types'
    require 'rm/common'
    require 'rm/composition'
    require 'rm/data_structures'
    require 'rm/demographic'
    require 'rm/security'
    require 'rm/ehr'
    require 'rm/integration'
    require 'rm/factory'
  end
end
