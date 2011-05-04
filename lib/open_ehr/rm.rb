$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenEHR
  module RM
    autoload :Common, 'rm/common'
    autoload :Composition, 'rm/composition'
    autoload :DataStructures, 'rm/data_structures'
    autoload :DataTypes, 'rm/data_types'
    autoload :Demographic, 'rm/demographic'
    autoload :EHR, 'rm/ehr'
    autoload :Integration, 'rm/integration'
    autoload :Security, 'rm/security'
    autoload :Support, 'rm/support'
  end
end
