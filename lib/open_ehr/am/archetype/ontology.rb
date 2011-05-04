module OpenEHR
  module AM
    module Archetype
      module Ontology
        class ArchetypeOntology
          attr_accessor :constraint_definitions, :specialisation_depth
          attr_accessor :term_attribute_names, :term_bindings
          attr_reader :terminologies_available, :term_definitions

          def initialize(args = { })
            self.specialisation_depth = args[:specialisation_depth]
            self.term_definitions = args[:term_definitions]
            self.constraint_definitions = args[:constraint_definitions]
            self.term_bindings = args[:term_bindings]
          end

          def term_definitions=(term_definitions)
            if term_definitions.nil?
              raise ArgumentError, 'term_definitions is mandatory'
            end
            @term_definitions = term_definitions
          end

          def term_codes
            return @term_definitions.values.collect {|value|
              value.collect {|term| term.code}}.flatten.uniq
          end

          def constraint_codes
            if @constraint_definitions.nil?
              return nil
            else
              return @constraint_definitions.values.collect {|value|
                value.collect {|term| term.code}}.flatten.uniq
            end
          end

          def terminologies_available
            return @term_bindings.keys
          end

          def constraint_binding(a_terminology, a_code)
          end

          def constraint_definition(a_lang, a_code)
          end

          def has_language?(a_lang)
          end

          def has_terminology?(a_terminology)
          end

          def term_binding(a_terminology, a_code)
          end

          def term_definition(a_lang, a_code)
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
        end

        class ARCHETYPE_TERM < ArchetypeTerm

        end
      end # end of Ontology
    end # end of Archetype
  end # end of AM
end # end of OpenEHR

