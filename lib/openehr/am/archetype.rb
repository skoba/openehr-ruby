require_relative '../rm/common/resource'

module OpenEHR
  module AM
    module Archetype

      module ADLDefinition
        CURRENT_ADL_VERSION = "1.4"
      end

      class Archetype < OpenEHR::RM::Common::Resource::AuthoredResource
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
          return @ontology.term_definition(:lang => a_lang, :code => @concept).items['text']
        end

        NODE_ID_PATTERN = /\A(?:at|ac|id)\d+(\.\d+)*\z/

        # A reference to a constraint definition (ADL "matches {use_node ac0001}")
        # is valid when it names a code actually present in the ontology's
        # constraint_definitions. True when there are no such references at
        # all; false (rather than vacuously true) when there are references
        # but the ontology has no constraint_definitions section.
        def constraint_references_valid?
          refs = collect(ConstraintModel::ConstraintRef) { |node| node.reference }
          return true if refs.empty?

          codes = ontology.constraint_codes
          return false if codes.nil?

          refs.all? { |ref| codes.include?(ref) }
        end

        # An ARCHETYPE_INTERNAL_REF's target_path must resolve to a node
        # physically present in this same definition tree.
        def internal_references_valid?
          refs = collect(ConstraintModel::ArchetypeInternalRef) { |node| node.target_path }
          paths = physical_paths
          refs.all? { |ref| paths.include?(ref) }
        end

        # True when a specialise header was present (i.e. this archetype
        # names a parent archetype to specialise).
        def is_specialised?
          !parent_archetype_id.nil?
        end

        # Composition of the three granular structural checks above.
        def is_valid?
          node_ids_valid? && constraint_references_valid? && internal_references_valid?
        end

        # physical_paths with each at/ac/id-code predicate replaced by its
        # ontology term text for +a_lang+ (falling back to the bare code
        # when no term text is found for it).
        def logical_paths(a_lang)
          physical_paths.map { |path| localize_path(path, a_lang) }
        end

        # Every node_id used in the definition, syntactically valid
        # (at/ac/id-code, optionally dotted for specialisation) and present
        # in the ontology's term codes.
        def node_ids_valid?
          node_ids = collect_node_ids
          codes = ontology.term_codes
          node_ids.all? { |id| id =~ NODE_ID_PATTERN && codes.include?(id) }
        end

        def node_ids_vaild?
          warn '[DEPRECATED] node_ids_vaild? is deprecated (typo); use node_ids_valid? instead'
          node_ids_valid?
        end

        # The archetype path of every node physically present in the
        # definition, in depth-first order, without duplicates (a node
        # without its own node_id shares its parent attribute's path).
        def physical_paths
          paths = []
          each_constraint_node(definition) { |node| paths << node.path if node.respond_to?(:path) }
          paths.uniq
        end

        # This gem does not parse ADL revision history, so a previous
        # version can never be determined from a parsed archetype.
        def previous_version
          nil
        end

        # Prefers the ontology's own (parser-derived) specialisation_depth
        # when available; otherwise falls back to what the archetype_id's
        # domain_concept specialisation suffix can tell us. ArchetypeID
        # currently only represents a single specialisation level, so this
        # fallback can only ever return 0 or 1.
        def specialisation_depth
          return ontology.specialisation_depth if ontology.specialisation_depth

          archetype_id.specialisation.nil? ? 0 : 1
        end

        private

        def each_constraint_node(node, &block)
          return if node.nil?

          yield node
          if node.respond_to?(:attributes) && node.attributes
            node.attributes.each { |attribute| each_constraint_node(attribute, &block) }
          end
          return unless node.respond_to?(:children) && node.children

          node.children.each { |child| each_constraint_node(child, &block) }
        end

        def collect(klass)
          found = []
          each_constraint_node(definition) { |node| found << yield(node) if node.is_a?(klass) }
          found
        end

        def collect_node_ids
          ids = []
          each_constraint_node(definition) { |node| ids << node.node_id if node.respond_to?(:node_id) && node.node_id }
          ids
        end

        def localize_path(path, a_lang)
          path.gsub(/\[((?:at|ac|id)\d+(?:\.\d+)*)\]/) do
            code = Regexp.last_match(1)
            text = term_text(code, a_lang)
            text ? "[#{text}]" : "[#{code}]"
          end
        end

        def term_text(code, a_lang)
          term = ontology.term_definition(:lang => a_lang, :code => code)
          term && term.items['text']
        rescue StandardError
          nil
        end

        public

        def self.create(args ={}, &block)
          archetype = new(args)
          if block_given?
            yield archetype
          end
          return archetype
        end

        def to_rm
          ::OpenEHR::RM::Factory.create(definition.rm_type_name,
                                        archetype_node_id: definition.archetype_node_id,
                                        name: definition
                                        )
        end
      end # end of Archetype
      # original file:
      # ref_imple_eiffel/components/adl_parser/src/interface/adl_definition.e

      class FlatArchetype < Archetype

      end

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
