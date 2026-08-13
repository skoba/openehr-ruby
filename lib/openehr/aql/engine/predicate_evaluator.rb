module OpenEHR
  module AQL
    # Evaluates a WHERE clause's boolean expression tree against a
    # Binding and the query's runtime params. E5 scope: comparisons
    # (reusing PathEvaluator for both sides), AND/OR/NOT and EXISTS. E12
    # adds LIKE (glob match, not SQL's %/_); E13 adds MATCHES against a
    # literal value list (a URI/TERMINOLOGY(...) operand names an
    # external value-set lookup this engine has no terminology service
    # wired for, so those raise a clear ExecutionError rather than
    # silently matching everything). Generic functionCall operands are
    # added by a later engine milestone.
    module PredicateEvaluator
      COMPARATORS = {
        '=' => :==, '!=' => :!=, '<' => :<, '<=' => :<=, '>' => :>, '>=' => :>=
      }.freeze

      # LIKE's glob syntax (AQL spec, not SQL's %/_): '?' matches exactly
      # one character, '*' matches zero or more, anything else is a
      # literal character - and the whole value must match, not a
      # substring.
      GLOB_TO_REGEXP = { '*' => '.*', '?' => '.' }.freeze

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
        when Model::LikeExpr
          evaluate_like(expression, binding, params)
        when Model::MatchesExpr
          evaluate_matches(expression, binding, params)
        else
          raise ExecutionError, "cannot evaluate a #{expression.class} WHERE expression yet"
        end
      end

      def evaluate_like(like_expr, binding, params)
        value = PathEvaluator.evaluate(like_expr.path, binding)
        pattern = resolve_operand(like_expr.operand, binding, params)
        return false if value.nil? || pattern.nil?

        like_regexp(pattern).match?(value.to_s)
      end

      def like_regexp(pattern)
        body = pattern.chars.map { |char| GLOB_TO_REGEXP[char] || Regexp.escape(char) }.join
        Regexp.new("\\A#{body}\\z", Regexp::MULTILINE)
      end

      def evaluate_matches(matches_expr, binding, params)
        value = PathEvaluator.evaluate(matches_expr.path, binding)
        return false if value.nil?

        case matches_expr.operand
        when Model::MatchesValueList
          matches_value_list?(value, matches_expr.operand, params)
        when Model::UriRef, Model::TerminologyFunctionCall
          raise ExecutionError,
                "MATCHES against a #{matches_expr.operand.class} names an external terminology service lookup " \
                '(a value-set expansion), which this engine has none wired in for - ' \
                'OpenEHR::TerminologyService only validates a single known code, it cannot expand a value set'
        else
          raise ExecutionError, "cannot evaluate a #{matches_expr.operand.class} MATCHES operand yet"
        end
      end

      def matches_value_list?(value, value_list, params)
        value_list.items.any? do |item|
          candidate = matches_list_item_value(item, params)
          !candidate.nil? && value == candidate
        end
      end

      def matches_list_item_value(item, params)
        case item
        when Model::Parameter
          lookup_param(item, params)
        when Model::Literal
          item.value
        when Model::TerminologyFunctionCall
          raise ExecutionError,
                "MATCHES against a #{item.class} names an external terminology service lookup " \
                '(a value-set expansion), which this engine has none wired in for - ' \
                'OpenEHR::TerminologyService only validates a single known code, it cannot expand a value set'
        else
          raise ExecutionError, "cannot evaluate a #{item.class} MATCHES value-list item yet"
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
