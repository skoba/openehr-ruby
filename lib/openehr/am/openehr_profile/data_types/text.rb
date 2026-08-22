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

          # C_CODE_REFERENCE is defined by Template.xsd (Template OM) as a
          # C_CODE_PHRASE extension carrying a referenceSetUri. nil is accepted
          # for tolerant parsing of real artifacts. valid_value? is inherited:
          # without a terminology service, this class cannot expand the URI's
          # reference set and must retain CCodePhrase's permissive behavior.
          class CCodeReference < CCodePhrase
            attr_reader :reference_set_uri

            def initialize(args = { })
              super
              self.reference_set_uri = args[:reference_set_uri]
            end

            def reference_set_uri=(reference_set_uri)
              if !reference_set_uri.nil? && reference_set_uri.empty?
                raise ArgumentError, 'invalid reference_set_uri'
              end
              @reference_set_uri = reference_set_uri
            end
          end
        end # of Text
      end # of Data_Types
    end # of OpenEHR Profile
  end # of AM
end # of OpenEHR
