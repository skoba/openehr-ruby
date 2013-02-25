$:.unshift(File.dirname(__FILE__))
include OpenEHR::RM::Common::Resource

module OpenEHR
  module AM
    module Archetype
      autoload :Assertion, 'archetype/assertion'
      autoload :ConstraintModel, 'archetype/constraint_model'
      autoload :Ontology, 'archetype/ontology'

      module ADLDefinition
        CURRENT_ADL_VERSION = "1.4"
      end

      class Archetype < AuthoredResource
        include ADLDefinition
        attr_reader :archetype_id, :concept, :definition, :ontology
        attr_accessor :uid, :adl_version, :parent_archetype_id, :invariants

        def initialize(args = {})
          super(args)
          self.adl_version = args[:adl_version] 
          self.archetype_id = args[:archetype_id]
          self.uid = args[:uid]
          self.concept = args[:concept]
          self.parent_archetype_id = args[:parent_archetype_id]
          self.definition = args[:definition]
          self.ontology = args[:ontology]
          self.invariants = args[:invariants]
        end

        def archetype_id=(archetype_id)
          if archetype_id.nil?
            raise ArgumentError, 'archetype_id is mandatory'
          end
          @archetype_id = archetype_id
        end

        def concept=(concept)
          if concept.nil?
            raise ArgumentError, 'concept is mandatory'
          end
          @concept = concept
        end

        def definition=(definition)
          if definition.nil?
            raise ArgumentError, 'definition is mandatory'
          end
          @definition = definition
        end

        def ontology=(ontology)
          if ontology.nil?
            raise ArgumentError, 'ontology is mandatory'
          end
          @ontology = ontology
        end

        def version
          return @archetype_id.version_id
        end

        def short_concept_name
          return @archetype_id.concept_name
        end

        def concept_name(a_lang)
          return @ontology.term_definition(:lang => a_lang, :code => @concept).items[:text]
        end

        def constraint_references_valid?
        end

        def internal_references_valid?
        end

        def is_specialised?
        end

        def is_valid?
        end

        def logical_paths(a_lang) 
        end

        def node_ids_vaild?
        end

        def physical_paths
        end

        def previous_version
        end

        def specialisation_depth
        end
        
        def self.create(args ={}, &block)
          archetype = new(args)
          if block_given?
            yield archetype
          end
          return archetype
        end

      end # end of Archetype
      # original file:
      # ref_imple_eiffel/components/adl_parser/src/interface/adl_definition.e

      class ValidityKind
        attr_reader :value

        MANDATORY = 1001
        OPTIONAL = 1002
        DISALLOWED = 1003

        def initialize(args = { })
          self.value = args[:value]
        end

        def value=(value)
          unless [MANDATORY, OPTIONAL, DISALLOWED].include? value
            raise ArgumentError, 'invalid value'
          end
          @value = value
        end
      end
    end # of Archetype
  end # of AM
end # of OpenEHR
