module OpenEHR
  module AM
    module Archetype
      module Ontology
        class ArchetypeOntology
          attr_accessor :specialisation_depth
          attr_accessor :term_attribute_names, :term_bindings
          attr_reader :term_definitions, :constraint_definitions

          def initialize(args = { })
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
            @term_definition_map = definition_mapper(term_definitions)
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

          def constraint_definitions=(constraint_definitions)
            @constraint_definition_map = definition_mapper(constraint_definitions)
            @constraint_definitions = constraint_definitions
          end

          def constraint_definition(args = {})
            return @constraint_definition_map[args[:lang]][args[:code]]
          end

          def has_language?(a_lang)
            return @term_definition_map.has_key? a_lang
          end

          def has_terminology?(a_terminology)
            return @term_bindings.has_key? a_terminology
          end

          def term_binding(args = { })
            
          end

          def term_definition(args = { })
            return @term_definition_map[args[:lang]][args[:code]]
          end

          private
          def definition_mapper(definitions)
            map = { }
            definitions.each do |lang, defs|
              defs_map = { }
              defs.each do |d|
                defs_map[d.code] = d.items
              end
              map[lang] = defs_map
            end
            return map
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

