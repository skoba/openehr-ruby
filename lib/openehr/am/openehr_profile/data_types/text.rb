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

            def valid_value?(value)
              return true if any_allowed?
              return false if value.nil?

              code, term = code_and_terminology(value)
              return false if code.nil?

              (code_list.nil? || code_list.include?(code)) &&
                (terminology_id.nil? || term.nil? || term == terminology_id.value)
            end

            private

            def code_and_terminology(value)
              if value.is_a?(String)
                [value, nil]
              elsif value.respond_to?(:code_string)
                [value.code_string, value.respond_to?(:terminology_id) ? value.terminology_id&.value : nil]
              else
                [nil, nil]
              end
            end
          end
        end # of Text
      end # of Data_Types
    end # of OpenEHR Profile
  end # of AM
end # of OpenEHR
