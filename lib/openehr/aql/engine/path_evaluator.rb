require_relative 'temporal_comparison'

module OpenEHR
  module AQL
    # Evaluates a columnExpr/terminal Model node against a Binding.
    #
    # SELECT paths ("o/data[at0001]/.../value/magnitude", "c/name/value")
    # walk one segment at a time: as long as the current value is
    # Pathable AND the segment names one of its *declared*
    # `path_attribute`s (the content-structure attributes PATHABLE
    # navigation was built for - see lib/openehr/rm/common/archetyped.rb),
    # the hop goes through PATHABLE#items_at_path (reusing its predicate
    # matching for node/archetype predicates). Everything else - RM
    # metadata that isn't part of that DSL (name, archetype_details,
    # composer, ...) and genuinely non-Pathable values (a DV_QUANTITY's
    # magnitude, a DV_TEXT's value) - is a plain attribute read via a
    # whitelisted public_send, never an arbitrary send driven by query
    # text. A predicate directly on an identifiedPath's own variable
    # (e.g. "c[at001]/..."), parameters and function calls are added by
    # later engine milestones.
    module PathEvaluator
      # Attribute hops not reachable through the path_attribute DSL.
      # Expand only when a real query needs another one - see the
      # project's "no arbitrary send" rule in the class comment above.
      #
      # These names are generic: allowed on any value that has a public
      # reader of that name (a value without one raises ExecutionError).
      # A new name should normally go into TYPED_TERMINAL_HOPS instead,
      # so that it is reachable only on the RM type it belongs to.
      ALLOWED_TERMINAL_HOPS = %w[code_string defining_code magnitude name time value].freeze

      # Attribute hops allowed on one RM type only (matched with is_a?,
      # so subclasses inherit them). Class names are resolved lazily:
      # this file is loaded before parts of the RM.
      TYPED_TERMINAL_HOPS = {
        # uid only here: VERSION and VERSIONED_OBJECT have one too (#88).
        'OpenEHR::RM::Common::Archetyped::Locatable' => %w[archetype_details archetype_node_id uid],
        'OpenEHR::RM::Common::Archetyped::Archetyped' => %w[archetype_id template_id],
        'OpenEHR::RM::Composition::EventContext' => %w[end_time setting start_time]
      }.freeze

      # Dataset::EHRRecord#ehr_id is already an unwrapped String (see
      # Dataset's own header comment), but AQL's "e/ehr_id/value" syntax
      # still expects a HierObjectID-shaped hop with its own #value -
      # this tiny wrapper bridges that gap.
      EhrIdValue = Struct.new(:value)

      module_function

      def evaluate(expression, binding)
        case expression
        when Model::IdentifiedPath
          evaluate_identified_path(expression, binding)
        when Model::Literal
          expression.value
        else
          raise ExecutionError, "cannot evaluate a #{expression.class} yet"
        end
      end

      # The operand a comparison or ORDER BY uses (#135): a path ending in
      # value whose owner is a DV_DATE_TIME or DV_DATE gives the owner,
      # so that it compares by TemporalComparison like the value itself.
      # Anything else, and SELECT, LIKE and MATCHES, see evaluate's
      # result (for …/value, the String as written).
      def evaluate_operand(expression, binding)
        owner = temporal_value_owner(expression, binding)
        owner.nil? ? evaluate(expression, binding) : owner
      end

      def temporal_value_owner(expression, binding)
        return nil unless expression.is_a?(Model::IdentifiedPath) && expression.path

        *owner_segments, last = expression.path.segments
        return nil unless last.attribute == 'value' && last.predicate.nil? && !owner_segments.empty?

        owner_path = Model::IdentifiedPath.new(variable: expression.variable, predicate: expression.predicate,
                                               path: Model::ObjectPath.new(segments: owner_segments))
        owner = evaluate_identified_path(owner_path, binding)
        TemporalComparison.temporal?(owner) ? owner : nil
      end

      def evaluate_identified_path(path, binding)
        raise ExecutionError, 'predicates on a SELECT variable are not yet supported' if path.predicate

        value = binding[path.variable]
        return value unless path.path

        path.path.segments.reduce(value) do |current, segment|
          current.nil? ? nil : navigate(current, segment)
        end
      end

      def navigate(current, segment)
        return navigate_ehr_record(current, segment) if current.is_a?(Dataset::EHRRecord)

        if declared_path_attribute?(current, segment)
          navigate_pathable(current, segment)
        else
          navigate_terminal(current, segment)
        end
      end

      # "e/ehr_id/value" and "e/ehr_status/..." always resolve (from
      # Dataset's own record shape); any other "e/..." path falls
      # through to whatever full RM::EHR::EHR the record carries, if
      # any, else resolves to nil rather than erroring - AQL's
      # path-absent-means-null semantics again, not a missing feature.
      def navigate_ehr_record(record, segment)
        raise ExecutionError, "path predicates on an EHR root are not supported (#{segment.attribute})" if segment.predicate

        case segment.attribute
        when 'ehr_id' then EhrIdValue.new(record.ehr_id)
        when 'ehr_status' then record.ehr_status
        else
          record.ehr.nil? ? nil : navigate(record.ehr, segment)
        end
      end

      def declared_path_attribute?(current, segment)
        current.is_a?(OpenEHR::RM::Common::Archetyped::Pathable) &&
          current.class.path_attributes.map(&:to_s).include?(segment.attribute)
      end

      # A path segment matching nothing is a legitimate "no value here"
      # (AQL's path-absent-means-null semantics, same convention as
      # PATHABLE#item_at_path itself), not an error - only an
      # *ambiguous* match (more than one item) is.
      def navigate_pathable(current, segment)
        matches = narrow_by_name(current.items_at_path(rm_path_for(segment)), segment.predicate)
        case matches.size
        when 0 then nil
        when 1 then matches.first
        else raise ExecutionError, "path segment #{segment.to_s.inspect} matched #{matches.size} items " \
                                    '(fan-out SELECT paths are not yet supported)'
        end
      end

      # A predicate's name value ("[id, 'Name']") is applied here, on the
      # items PATHABLE returned for the id alone, instead of being written
      # into the path text: PATHABLE path text quotes the name with
      # apostrophes and cannot hold a name that contains one (issue #65).
      # Same rule as Pathable.select_by_predicate: the node's name.value
      # must equal the given name.
      def narrow_by_name(items, predicate)
        name = predicate_name(predicate)
        return items if name.nil?

        items.select do |item|
          item.respond_to?(:name) && item.name.respond_to?(:value) && item.name.value == name
        end
      end

      def predicate_name(predicate)
        return nil if predicate.nil? || predicate.value.nil?
        return predicate.value if predicate.value.is_a?(String)

        kind = predicate.is_a?(Model::ArchetypePredicate) ? 'archetype' : 'node'
        raise ExecutionError, "cannot evaluate a #{predicate.value.class} #{kind} predicate value yet"
      end

      def navigate_terminal(current, segment)
        raise ExecutionError, "path predicates on a non-Pathable value are not supported (#{segment.attribute})" if segment.predicate
        unless terminal_hop_allowed?(current, segment.attribute)
          raise ExecutionError, "unsupported path attribute #{segment.attribute.inspect} on a #{current.class}"
        end

        current.public_send(segment.attribute)
      end

      def terminal_hop_allowed?(current, attribute)
        return current.respond_to?(attribute) if ALLOWED_TERMINAL_HOPS.include?(attribute)

        TYPED_TERMINAL_HOPS.any? do |class_name, attributes|
          attributes.include?(attribute) && current.is_a?(Object.const_get(class_name))
        end
      end

      # PATHABLE path text for the segment, by id only - see narrow_by_name
      # for the name value.
      def rm_path_for(segment)
        return "/#{segment.attribute}" unless segment.predicate

        "/#{segment.attribute}[#{predicate_id_text(segment.predicate)}]"
      end

      def predicate_id_text(predicate)
        case predicate
        when Model::ArchetypePredicate then predicate.archetype_id
        when Model::NodePredicate then predicate.code
        else
          raise ExecutionError, "cannot evaluate a #{predicate.class} path predicate yet"
        end
      end
    end
  end
end
