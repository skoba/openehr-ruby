module OpenEHR
  module AQL
    # Evaluates a WHERE clause's boolean expression tree against a
    # Binding and the query's runtime params. E5 scope: comparisons
    # (reusing PathEvaluator for both sides), AND/OR/NOT and EXISTS.
    # LIKE, MATCHES and functionCall operands are added by later engine
    # milestones.
    module PredicateEvaluator
      COMPARATORS = {
        '=' => :==, '!=' => :!=, '<' => :<, '<=' => :<=, '>' => :>, '>=' => :>=
      }.freeze

      module_function

      # `expression` is nil when there is no WHERE clause at all.
      def matches?(expression, binding, params)
        case expression
        when nil
          true
        when Model::Comparison
          evaluate_comparison(expression, binding, params)
        when Model::AndExpr
          matches?(expression.left, binding, params) && matches?(expression.right, binding, params)
        when Model::OrExpr
          matches?(expression.left, binding, params) || matches?(expression.right, binding, params)
        when Model::NotExpr
          !matches?(expression.operand, binding, params)
        when Model::ExistsExpr
          !PathEvaluator.evaluate(expression.path, binding).nil?
        else
          raise ExecutionError, "cannot evaluate a #{expression.class} WHERE expression yet"
        end
      end

      # A comparison against an absent (nil) value is neither true nor
      # false in AQL/SQL terms - it simply fails to select the row, the
      # same as SQL's NULL-comparison-is-UNKNOWN convention.
      def evaluate_comparison(comparison, binding, params)
        left = resolve_operand(comparison.left, binding, params)
        right = resolve_operand(comparison.right, binding, params)
        return false if left.nil? || right.nil?

        compare(left, comparison.operator, right)
      end

      def resolve_operand(node, binding, params)
        return lookup_param(node, params) if node.is_a?(Model::Parameter)

        PathEvaluator.evaluate(node, binding)
      end

      def lookup_param(parameter, params)
        return params[parameter.name.to_sym] if params.key?(parameter.name.to_sym)
        return params[parameter.name] if params.key?(parameter.name)

        raise UnboundParameterError, "unbound parameter: $#{parameter.name}"
      end

      def compare(left, operator, right)
        method = COMPARATORS.fetch(operator) { raise ExecutionError, "unknown comparison operator #{operator.inspect}" }
        left.public_send(method, right)
      end
    end
  end
end
