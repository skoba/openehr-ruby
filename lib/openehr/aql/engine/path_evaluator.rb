module OpenEHR
  module AQL
    # Evaluates a columnExpr/terminal Model node against a Binding. E2
    # scope: a bare identifiedPath (just the FROM variable itself, e.g.
    # "c") and primitive literals. Walking a trailing objectPath via
    # PATHABLE#items_at_path, node/archetype predicates, parameters and
    # function calls are added by later engine milestones.
    module PathEvaluator
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
        value = binding[path.variable]
        raise ExecutionError, 'SELECT paths beyond a bare variable are not yet supported' if path.path
        raise ExecutionError, 'predicates on a SELECT variable are not yet supported' if path.predicate

        value
      end
    end
  end
end
