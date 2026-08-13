require_relative 'binding'

module OpenEHR
  module AQL
    # Walks a FromClause's containment tree against a Dataset, producing
    # one Binding per match.
    #
    # An EHR root variable (bound to the Dataset::EHRRecord itself - not
    # an OpenEHR::RM::EHR::EHR - since a Dataset element doesn't have to
    # carry one; see Dataset's own header comment), a right-recursive
    # CONTAINS chain searching a matched Locatable's *entire* subtree
    # (any depth, via Pathable#path_children) for the next class,
    # archetype-predicate filtering, AND/OR-grouped sibling branches
    # (cross-product / union of each branch's matches), NOT CONTAINS
    # (parent matches survive only when the negated class is absent),
    # and an EHR-level standardPredicate (e.g. "[ehr_id/value=$ehr_id]",
    # reusing PathEvaluator/PredicateEvaluator's existing comparison
    # machinery rather than new bespoke logic). standardPredicate/
    # nodePredicate filtering on non-EHR CONTAINS classes is added by a
    # later engine milestone (see predicate_matches? below).
    class ContainsResolver
      def initialize(from_clause, dataset, params: {})
        @root = from_clause.containment
        @dataset = dataset
        @params = params
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
        when Model::ContainmentAnd
          resolve_containment_and(node, ehr_record, pool)
        when Model::ContainmentOr
          resolve_containment_or(node, ehr_record, pool)
        else
          raise ExecutionError, "cannot execute a #{node.class} containment yet"
        end
      end

      def resolve_class_expression(class_expression, ehr_record, pool)
        if ehr_root?(class_expression)
          return [] unless ehr_predicate_matches?(ehr_record, class_expression.predicate)

          return [[variables_for(class_expression, ehr_record), ehr_record]]
        end

        pool.select { |candidate| matches?(candidate, class_expression) }
            .map { |candidate| [variables_for(class_expression, candidate), candidate] }
      end

      def resolve_containment(containment, ehr_record, pool)
        parent_matches = resolve(containment.parent, ehr_record, pool)
        return negated_matches(containment, ehr_record, parent_matches) if containment.negated

        parent_matches.flat_map do |parent_vars, parent_obj|
          resolve(containment.child, ehr_record, descendant_pool(parent_obj, ehr_record)).map do |child_vars, child_obj|
            [parent_vars.merge(child_vars), child_obj]
          end
        end
      end

      # "A NOT CONTAINS B": a parent match survives only when B has no
      # match anywhere in that parent's subtree. B never binds a
      # variable (there's nothing to bind an absence to).
      def negated_matches(containment, ehr_record, parent_matches)
        parent_matches.select do |_parent_vars, parent_obj|
          resolve(containment.child, ehr_record, descendant_pool(parent_obj, ehr_record)).empty?
        end
      end

      # "A CONTAINS (B AND C)": both branches must match somewhere in
      # the same pool; every combination of a B-match and a C-match
      # becomes its own binding (AQL has no correlation between sibling
      # branches beyond sharing a parent).
      def resolve_containment_and(node, ehr_record, pool)
        left_matches = resolve(node.left, ehr_record, pool)
        return [] if left_matches.empty?

        right_matches = resolve(node.right, ehr_record, pool)
        return [] if right_matches.empty?

        left_matches.flat_map do |left_vars, _left_obj|
          right_matches.map { |right_vars, right_obj| [left_vars.merge(right_vars), right_obj] }
        end
      end

      # "A CONTAINS (B OR C)": either branch matching is enough; each
      # branch's matches contribute their own bindings independently.
      def resolve_containment_or(node, ehr_record, pool)
        resolve(node.left, ehr_record, pool) + resolve(node.right, ehr_record, pool)
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

      # An EHR-root predicate (e.g. "[ehr_id/value=$ehr_id]") is a
      # standardPredicate/PredicateAnd/PredicateOr tree evaluated against
      # the Dataset::EHRRecord itself, reusing PathEvaluator.navigate
      # (which already special-cases EHRRecord) and
      # PredicateEvaluator.compare/lookup_param rather than new
      # comparison code.
      def ehr_predicate_matches?(ehr_record, predicate)
        case predicate
        when nil
          true
        when Model::StandardPredicate
          standard_ehr_predicate_matches?(ehr_record, predicate)
        when Model::PredicateAnd
          ehr_predicate_matches?(ehr_record, predicate.left) && ehr_predicate_matches?(ehr_record, predicate.right)
        when Model::PredicateOr
          ehr_predicate_matches?(ehr_record, predicate.left) || ehr_predicate_matches?(ehr_record, predicate.right)
        else
          raise ExecutionError, "cannot evaluate a #{predicate.class} EHR predicate yet"
        end
      end

      def standard_ehr_predicate_matches?(ehr_record, predicate)
        left = ehr_predicate_operand(ehr_record, predicate.path)
        right = ehr_predicate_operand(ehr_record, predicate.operand)
        return false if left.nil? || right.nil?

        PredicateEvaluator.compare(left, predicate.operator, right)
      end

      def ehr_predicate_operand(ehr_record, operand)
        return PredicateEvaluator.lookup_param(operand, @params) if operand.is_a?(Model::Parameter)
        return operand.value if operand.is_a?(Model::Literal)
        return operand unless operand.is_a?(Model::ObjectPath)

        operand.segments.reduce(ehr_record) { |current, segment| current.nil? ? nil : PathEvaluator.navigate(current, segment) }
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
