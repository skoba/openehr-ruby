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
      ALLOWED_TERMINAL_HOPS = %w[magnitude name value].freeze

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
        matches = current.items_at_path(rm_path_for(segment))
        case matches.size
        when 0 then nil
        when 1 then matches.first
        else raise ExecutionError, "path segment #{segment.to_s.inspect} matched #{matches.size} items " \
                                    '(fan-out SELECT paths are not yet supported)'
        end
      end

      def navigate_terminal(current, segment)
        raise ExecutionError, "path predicates on a non-Pathable value are not supported (#{segment.attribute})" if segment.predicate
        unless ALLOWED_TERMINAL_HOPS.include?(segment.attribute)
          raise ExecutionError, "unsupported path attribute #{segment.attribute.inspect} on a #{current.class}"
        end

        current.public_send(segment.attribute)
      end

      def rm_path_for(segment)
        return "/#{segment.attribute}" unless segment.predicate

        "/#{segment.attribute}[#{predicate_path_text(segment.predicate)}]"
      end

      def predicate_path_text(predicate)
        case predicate
        when Model::ArchetypePredicate
          predicate.archetype_id
        when Model::NodePredicate
          node_predicate_path_text(predicate)
        else
          raise ExecutionError, "cannot evaluate a #{predicate.class} path predicate yet"
        end
      end

      def node_predicate_path_text(predicate)
        return predicate.code unless predicate.value

        unless predicate.value.is_a?(String)
          raise ExecutionError, "cannot evaluate a #{predicate.value.class} node predicate value yet"
        end

        "#{predicate.code}, '#{predicate.value}'"
      end
    end
  end
end
