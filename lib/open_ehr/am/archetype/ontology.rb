module OpenEHR
  module AM
    module Archetype
      module Ontology
        class ArchetypeOntology
          attr_accessor :specialisation_depth, :primary_language
          attr_accessor :term_attribute_names, :term_bindings
          attr_accessor :languages_available, :terminologies_available
          attr_reader :term_definitions, :constraint_definitions

          def initialize(args = { })
            self.primary_language = args[:primary_language]
            self.languages_available = args[:languages_available]
            self.terminologies_available = args[:terminologies_available]
            self.specialisation_depth = args[:specialisation_depth]
            self.term_definitions = args[:term_definitions]
            if args[:constraint_definitions]
              self.constraint_definitions = args[:constraint_definitions]
            end
            self.term_bindings = args[:term_bindings]
          end

          def term_definitions=(term_definitions)
            if term_definitions.nil?
              raise ArgumentError, 'term_definitions is mandatory'
            end
            @term_definitions = term_definitions
          end

          def term_codes
            code_set @term_definitions
          end

          def constraint_codes
            if @constraint_definitions.nil?
              return nil
            else
              code_set @constraint_definitions
            end
          end

          def constraint_binding(a_terminology, a_code)
            
          end

          def constraint_definitions=(constraint_definitions)
            @constraint_definitions = constraint_definitions
          end

          def constraint_definition(args = {})
            return @constraint_definitions[args[:lang]][args[:code]]
          end

          def has_language?(a_lang)
            return @term_definitions.has_key? a_lang
          end

          def has_terminology?(a_terminology)
            return @term_bindings.has_key? a_terminology
          end

          def term_binding(args = { })
            return @term_bindings[args[:terminology]][args[:code]]
          end

          def term_definition(args = { })
            return @term_definitions[args[:lang]][args[:code]]
          end

          protected
          def code_set(definitions)
            codes = definitions.values.inject([]) do |codes, item|
              item.keys
            end
            codes.uniq
          end
        end

        class ARCHETYPE_ONTOLOGY < ArchetypeOntology

        end

        class ArchetypeTerm
          attr_accessor :items
          attr_reader :code

          def initialize(args = { })
            self.code = args[:code]
            self.items =args[:items]
          end            

          def code=(code)
            if code.nil? or code.empty?
              raise ArgumentError, 'code is mandatory'
            end
            @code = code
          end

          def keys
            if items.nil?
              return Set.new
            else
              return Set.new(@items.keys)
            end
          end

          def method_missing(key)
            return @items[key.to_sym]
          end
        end

        class ARCHETYPE_TERM < ArchetypeTerm

        end
      end # end of Ontology
    end # end of Archetype
  end # end of AM
end # end of OpenEHR

