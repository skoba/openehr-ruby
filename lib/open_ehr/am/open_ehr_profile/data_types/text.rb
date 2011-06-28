$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module OpenEHR
  module AM
    module OpenEHRProfile
      module DataTypes
        module Text
          class C_CODE_PHASE < OpenEhr::AM::Archetype::Constraint_Model::C_DOMAIN_TYPE
          end
        end
      end # of Data_Types
    end # of OpenEHR Profile
  end # of RM
end # of OpenEHR
