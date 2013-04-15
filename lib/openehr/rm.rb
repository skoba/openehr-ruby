$:.unshift(File.dirname(__FILE__))
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
    include Factory
  end
end
