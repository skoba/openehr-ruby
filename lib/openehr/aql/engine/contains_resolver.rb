require_relative 'binding'

module OpenEHR
  module AQL
    # Walks a FromClause's containment tree against a Dataset, producing
    # one Binding per match.
    #
    # E3 scope: an EHR root variable (bound to the Dataset::EHRRecord
    # itself - not an OpenEHR::RM::EHR::EHR - since a Dataset element
    # doesn't have to carry one; see Dataset's own header comment), a
    # right-recursive CONTAINS chain searching a matched Locatable's
    # *entire* subtree (any depth, via Pathable#path_children) for the
    # next class, and archetype-predicate filtering. AND/OR/NOT CONTAINS,
    # standardPredicate/nodePredicate filtering, and an EHR-level
    # predicate (e.g. "[ehr_id/value=$ehr_id]") are added by later
    # engine milestones.
    class ContainsResolver
      def initialize(from_clause, dataset)
        @root = from_clause.containment
        @dataset = dataset
      end

      def each_binding
        return enum_for(:each_binding) unless block_given?

        @dataset.each_ehr do |ehr_record|
          resolve(@root, ehr_record, ehr_record.compositions).each do |variables, _bound|
            yield Binding.new(ehr_record: ehr_record, variables: variables)
          end
        end
      end

      private

      # Returns an Array of [variables_hash, bound_object] pairs. `pool`
      # is the Enumerable of Pathable candidates in scope for this node:
      # an EHR record's top-level compositions at the root, or a parent
      # match's full recursive descendant set below a CONTAINS.
      # `bound_object` lets the caller (a further CONTAINS) compute the
      # next-level pool from wherever this node ended up.
      def resolve(node, ehr_record, pool)
        case node
        when Model::ClassExpression
          resolve_class_expression(node, ehr_record, pool)
        when Model::Containment
          resolve_containment(node, ehr_record, pool)
        else
          raise ExecutionError, "cannot execute a #{node.class} containment yet"
        end
      end

      def resolve_class_expression(class_expression, ehr_record, pool)
        return [[variables_for(class_expression, ehr_record), ehr_record]] if ehr_root?(class_expression)

        pool.select { |candidate| matches?(candidate, class_expression) }
            .map { |candidate| [variables_for(class_expression, candidate), candidate] }
      end

      def resolve_containment(containment, ehr_record, pool)
        raise ExecutionError, 'NOT CONTAINS is not yet supported' if containment.negated

        resolve(containment.parent, ehr_record, pool).flat_map do |parent_vars, parent_obj|
          child_pool = descendant_pool(parent_obj, ehr_record)
          resolve(containment.child, ehr_record, child_pool).map do |child_vars, child_obj|
            [parent_vars.merge(child_vars), child_obj]
          end
        end
      end

      def descendant_pool(bound_object, ehr_record)
        return ehr_record.compositions if bound_object.equal?(ehr_record)

        descendants_of(bound_object)
      end

      # A subtree walk (any depth) over Pathable#path_children, matching
      # real AQL CONTAINS semantics ("anywhere below", not just direct
      # children).
      def descendants_of(root)
        results = []
        queue = child_values(root)
        until queue.empty?
          node = queue.shift
          next unless node.is_a?(OpenEHR::RM::Common::Archetyped::Pathable)

          results << node
          queue.concat(child_values(node))
        end
        results
      end

      def child_values(node)
        node.path_children.values.flat_map { |value| value.is_a?(Array) ? value : [value] }
      end

      def matches?(candidate, class_expression)
        return false unless OpenEHR::RM.subtype_of?(candidate, class_expression.class_name)

        predicate_matches?(candidate, class_expression.predicate)
      end

      def predicate_matches?(candidate, predicate)
        case predicate
        when nil
          true
        when Model::ArchetypePredicate
          candidate.respond_to?(:archetype_node_id) && candidate.archetype_node_id == predicate.archetype_id
        else
          raise ExecutionError, "cannot evaluate a #{predicate.class} predicate yet"
        end
      end

      def variables_for(class_expression, matched)
        return {} unless class_expression.variable

        { class_expression.variable => matched }
      end

      def ehr_root?(class_expression)
        class_expression.class_name.upcase == 'EHR'
      end
    end
  end
end
