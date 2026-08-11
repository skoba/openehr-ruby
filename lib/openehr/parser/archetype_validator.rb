require_relative 'exception'

module OpenEHR
  module Parser
    # Post-parse semantic validator, checking a parsed archetype
    # against the VARID..VDFPT rules (Beale07, p.100). VARID/VARDF/
    # VARON/VDFAI are already enforced structurally by the RM/AM
    # object model itself (their setters raise on construction), so
    # they can never actually fail here - they're still checked
    # explicitly, both for rule-traceability and so a validator run
    # against a duck-typed object (not necessarily a real
    # OpenEHR::AM::Archetype::Archetype) stays honest.
    class ArchetypeValidator
      Validation = Exception::Validation

      def initialize(archetype)
        @archetype = archetype
      end

      def errors
        RULES.filter_map { |rule| send(rule) }
      end

      def valid?
        errors.empty?
      end

      def validate!
        error = errors.first
        raise error if error
      end

      # Checks +rm_root+ against the archetype's definition, returning
      # a path-annotated OpenEHR::Parser::Exception::Validation::
      # InstanceNonConformant for the first violation found (path
      # resolved via rm_root.path_of_item, the PATHABLE navigation
      # method), or [] when rm_root fully conforms.
      def validate_instance(rm_root)
        return [] if @archetype.definition.valid_value?(rm_root)

        _node, value = @archetype.definition.find_violation(rm_root)
        message = "value does not conform to #{@archetype.archetype_id.value}"
        [Validation::InstanceNonConformant.new(message, resolve_path(rm_root, value))]
      end

      private

      def resolve_path(rm_root, value)
        return nil unless rm_root.respond_to?(:path_of_item)

        rm_root.path_of_item(value)
      end

      def varid
        Validation::VARID.new(Validation::VARID::MESSAGE) if @archetype.archetype_id.nil?
      end

      def vardf
        Validation::VARDF.new(Validation::VARDF::MESSAGE) if @archetype.definition.nil?
      end

      def varon
        Validation::VARON.new(Validation::VARON::MESSAGE) if @archetype.ontology.nil?
      end

      def varcn
        return if @archetype.concept.nil?
        return if @archetype.ontology.term_codes.include?(@archetype.concept)

        Validation::VARCN.new(Validation::VARCN::MESSAGE)
      end

      def vardt
        definition_type = @archetype.definition.rm_type_name.to_s.upcase
        id_type = @archetype.archetype_id.rm_entity.to_s.upcase
        return if definition_type == id_type

        Validation::VARDT.new(Validation::VARDT::MESSAGE)
      end

      def vatdf
        Validation::VATDF.new(Validation::VATDF::MESSAGE) unless @archetype.node_ids_valid?
      end

      def vacdf
        Validation::VACDF.new(Validation::VACDF::MESSAGE) unless @archetype.constraint_references_valid?
      end

      # In practice this can never actually fail through this gem's own
      # object model: CArchetypeRoot#archetype_id= already rejects
      # anything but a well-typed ArchetypeID at construction time.
      # Still checked genuinely (rather than a hardcoded pass) in case
      # +archetype+ is a duck-typed object built some other way.
      def vdfai
        return if archetype_roots(@archetype.definition).all? do |id|
          id.is_a?(OpenEHR::RM::Support::Identification::ArchetypeID)
        end

        Validation::VDFAI.new(Validation::VDFAI::MESSAGE)
      end

      def archetype_roots(node, found = [])
        return found if node.nil?

        found << node.archetype_id if node.is_a?(OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot)
        if node.respond_to?(:attributes) && node.attributes
          node.attributes.each { |attribute| archetype_roots(attribute, found) }
        end
        if node.respond_to?(:children) && node.children
          node.children.each { |child| archetype_roots(child, found) }
        end
        found
      end

      def vdfpt
        return if @archetype.internal_references_valid? &&
                  @archetype.physical_paths.all? { |path| OpenEHR::Path.valid?(path) }

        Validation::VDFPT.new(Validation::VDFPT::MESSAGE)
      end

      RULES = %i[varid vardf varon varcn vardt vatdf vacdf vdfai vdfpt].freeze
      private_constant :RULES
    end
  end
end
