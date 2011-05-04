
module OpenEHR
  module RM
    module Support
      module Terminology
        class CodeSetAccess
          def all_codes
            raise NotImplementedError, "all_codes must be implemented"
          end

          def has_code(a_code)
            raise NotImplementedError, "has_code must be implemented"
          end

          def has_lang(a_lang)
            raise NotImplementedError, "has_lang must be implemented"
          end

          def id
            raise NotImplementedError, "id must be returned"
          end
        end

        module OpenEHRCodeSetIdentifier
          CODE_SET_ID_CHARACER_SETS = "character sets".freeze
          CODE_SET_ID_COMPRESSION_ALGORITHMS = "compression algorithms".freeze
          CODE_SET_ID_COUNTRIES = "countries".freeze
          CODE_SET_ID_INTEGRITY_CHECK_ALGORITHMS = "integrity check algorithms".freeze
          CODE_SET_ID_LANGUAGES = "languages".freeze
          CODE_SET_ID_MEDIA_TYPES = "media types".freeze
          def valid_code_set_id(an_id)
            !@an_id.nil?
          end
        end

        module OpenEHRTerminologyGroupIdentifiers
          GROUP_ID_ATTESTATION_REASON = "attestation reason".freeze
          GROUP_ID_AUDIT_CHANGE_TYPE = "audit change type".freeze
          GROUP_ID_COMPOSITION_CATEGORY = "composition category".freeze
          GROUP_ID_MATH_FUNCTION = "event math function".freeze
          GROUP_ID_INSTRUCTION_STATES = "instruction states".freeze
          GROUP_ID_INSTRUCTION_TRANSITIONS = "instruction transitions".freeze
          GROUP_ID_NULL_FLAVOURS = "null flavours".freeze
          GROUP_ID_PARTICIPATION_FUNCTION = "participation function".freeze
          GROUP_ID_PARTICIPATION_MODE = "participation mode".freeze
          GROUP_ID_PROPERTY = "property".freeze
          GROUP_ID_SETTING = "setting".freeze.freeze
          GROUP_ID_SUBJECT_RELATIONSHIP = "subject relationship".freeze
          GROUP_ID_TERM_MAPPING_PURPOSE = "term mapping purpose".freeze
          GROUP_ID_VERSION_LIFECYCLE_STATE = "version lifecycle state".freeze
          TERMINOLOGY_ID = "openehr".freeze
        end

        class TerminologyAccess
          attr_reader :id

          def initialize(args = {})
            self.id = args[:id]
          end

          def all_codes
            raise NotImplementedError, "all_codes is not implemented"
          end

          def codes_for_group_id(group_id)
            raise NotImplementedError, "codes_for_group_id is not implemented"
          end

          def codes_for_group_name(name, lang)
            raise NotImplementedError, "codes_for_group_name is not implemented"
          end

          def has_code_for_group_id(group_id, a_code)
            
          end

          def id=(id)
            @terminology = Terminology.find_all_by_name(id)
            @id = id
          end

          def rubric_for_code(code, lang)
            return Terminology.find(:first, :conditions => {:code => code,
                                      :lang => lang})
          end

          private
          def id_exists
            if id.nil?
              raise ArgumentError, "id must not be nil"
            elsif id.empty?
              raise ArgumentError, "id must not be empty"
            end
          end
        end

        class TerminologyService
          include OpenEHRCodeSetIdentifier, OpenEHRTerminologyGroupIdentifiers

          def code_set(name)
            raise NotImplementedError, "code_set is not implemented"
          end

          def code_set_for_id(id)
            raise NotImplementedError, "code_set_for_id is not implemented"
          end

          def code_set_identifiers
            raise NotImplementedError, "code_set_for_identifiers is not implemented"
          end

          def has_code_set(name)
            raise NotImplementedError, "has_code_set is not implemented"
          end

          def has_terminology?(name)
            raise NotImplementedError, "has_terminology is not implemented"
          end

          def openehr_code_sets
            raise NotImplementedError, "openehr_code_set is not implemented"
          end

          def terminology(name)
            return TerminologyAccess.new(:id => name)
          end
          
          def terminology_identifiers
            raise NotImplementedError, "terminology_identiferes is not implemented"
          end
        end 
      end # of Terminology
    end # of Support
  end # of RM
end # of OpenEHR
