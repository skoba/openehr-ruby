require_relative '../../archetype/constraint_model'

module OpenEHR
  module AM
    module OpenEHRProfile
      module DataTypes
        module Text
          class CCodePhrase < OpenEHR::AM::Archetype::ConstraintModel::CDomainType
            attr_accessor :terminology_id, :code_list

            def initialize(args = { })
              super
              self.terminology_id = args[:terminology_id]
              self.code_list = args[:code_list]
              self.assumed_value = args[:assumed_value]
            end
            
            def any_allowed?
              @terminology_id.nil? && @code_list.nil?
            end
          end
        end # of Text
      end # of Data_Types
    end # of OpenEHR Profile
  end # of AM
end # of OpenEHR
