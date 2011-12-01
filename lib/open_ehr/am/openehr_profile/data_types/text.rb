$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
include OpenEHR::AM::Archetype::ConstraintModel

module OpenEHR
  module AM
    module OpenEHRProfile
      module DataTypes
        module Text
          class CCodePhase < CDomainType
            attr_accessor :terminology_id, :code_list
            def initialize(args = { })
              super
              self.terminology_id = args[:terminology_id]
              self.code_list = args[:code_list]
            end
          end
        end
      end # of Data_Types
    end # of OpenEHR Profile
  end # of RM
end # of OpenEHR
