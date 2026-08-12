require_relative 'lexer'
require_relative 'model'

module OpenEHR
  module AQL
    # Recursive-descent parser over the Lexer's token stream. Method names
    # mirror the official AqlParser.g4 rule names (see the rule cited in
    # each method's comment) so the implementation stays traceable against
    # the reference grammar. Each project-plan milestone implements a
    # subset of these rules; a construct a milestone hasn't reached yet is
    # simply never consumed, so parsing it falls through to the nearest
    # "expected X, got Y" ParseError instead of being silently misparsed.
    class Parser
      def initialize(tokens)
        @tokens = tokens
        @pos = 0
      end

      # selectQuery : selectClause fromClause whereClause? orderByClause? limitClause? SYM_DOUBLE_DASH? EOF ;
      # The trailing SYM_DOUBLE_DASH (a batch-file query terminator) isn't
      # needed by any example and is deferred to M9.
      def parse_select_query
        select_clause = parse_select_clause
        from_clause = parse_from_clause
        where_clause = check(:where) ? parse_where_clause : nil
        order_by_clause = check(:order) ? parse_order_by_clause : nil
        limit_clause = check(:limit) ? parse_limit_clause : nil
        expect(:eof)
        Model::Query.new(select_clause: select_clause, from_clause: from_clause, where_clause: where_clause,
                          order_by_clause: order_by_clause, limit_clause: limit_clause)
      end

      PRIMITIVE_TOKEN_TYPES = %i[string integer real sci_integer sci_real boolean null].freeze
      DESCENDING_DIRECTIONS = %i[desc descending].freeze
      AGGREGATE_FUNCTION_TYPES = %i[count min max sum avg].freeze
      FUNCTION_NAME_TYPES = %i[length position substring concat concat_ws abs mod ceil floor round
                                now current_date current_time current_date_time current_timezone].freeze

      private

      # selectClause : SELECT DISTINCT? top? selectExpr (SYM_COMMA selectExpr)* ;
      def parse_select_clause
        expect(:select)
        distinct = match(:distinct)
        top = check(:top) ? parse_top : nil
        columns = [parse_select_expr]
        columns << parse_select_expr while match(:comma)
        Model::SelectClause.new(columns: columns, distinct: distinct, top: top)
      end

      # top : TOP INTEGER direction=(FORWARD|BACKWARD)? ; (deprecated)
      def parse_top
        expect(:top)
        count = expect(:integer).value
        direction = if match(:forward)
                      :forward
                    elsif match(:backward)
                      :backward
                    end
        Model::Top.new(count: count, direction: direction)
      end

      # selectExpr : columnExpr (AS aliasName=IDENTIFIER)? ;
      def parse_select_expr
        expression = parse_column_expr
        alias_name = match(:as) ? expect(:identifier).value : nil
        Model::SelectColumn.new(expression: expression, alias_name: alias_name)
      end

      # columnExpr : identifiedPath | primitive | aggregateFunctionCall | functionCall ;
      def parse_column_expr
        return parse_aggregate_function_call if aggregate_function_ahead?
        return parse_function_call if function_call_ahead?
        return parse_identified_path if check(:identifier)
        return parse_primitive if primitive_ahead?

        raise error("expected a path, a literal value or a function call, got #{describe(peek)}")
      end

      # fromClause : FROM fromExpr ; fromExpr : containsExpr ;
      def parse_from_clause
        expect(:from)
        Model::FromClause.new(containment: parse_contains_or_expr)
      end

      # containsExpr : ... | containsExpr OR containsExpr | ... ;
      # AND binds tighter than OR (same precedence-climbing rewrite of the
      # reference grammar's left recursion as whereExpr, M5).
      def parse_contains_or_expr
        left = parse_contains_and_expr
        left = Model::ContainmentOr.new(left: left, right: parse_contains_and_expr) while match(:or)
        left
      end

      # containsExpr : ... | containsExpr AND containsExpr | ... ;
      def parse_contains_and_expr
        left = parse_contains_primary
        left = Model::ContainmentAnd.new(left: left, right: parse_contains_primary) while match(:and)
        left
      end

      # containsExpr : ... | SYM_LEFT_PAREN containsExpr SYM_RIGHT_PAREN ;
      def parse_contains_primary
        return parse_containment_chain unless match(:left_paren)

        expr = parse_contains_or_expr
        expect(:right_paren)
        expr
      end

      # containsExpr : classExprOperand (NOT? CONTAINS containsExpr)? ;
      # The right-recursive "A CONTAINS B CONTAINS C ..." chain, with an
      # optional NOT flag on each containment edge.
      def parse_containment_chain
        operand = parse_class_expr_operand
        negated = match(:not)
        if negated
          expect(:contains)
        elsif !match(:contains)
          return operand
        end
        Model::Containment.new(parent: operand, child: parse_contains_or_expr, negated: negated)
      end

      # classExprOperand : IDENTIFIER variable=IDENTIFIER? pathPredicate? #classExpression | ... ;
      # (archetypePredicate/nodePredicate alternatives inside pathPredicate are added by M3)
      def parse_class_expr_operand
        class_name = expect(:identifier).value
        variable = check(:identifier) ? advance.value : nil
        predicate = check(:left_bracket) ? parse_path_predicate : nil
        Model::ClassExpression.new(class_name: class_name, variable: variable, predicate: predicate)
      end

      # pathPredicate : SYM_LEFT_BRACKET (standardPredicate | archetypePredicate | nodePredicate) SYM_RIGHT_BRACKET ;
      # standardPredicate's shape (objectPath COMPARISON_OPERATOR
      # pathPredicateOperand) is literally nodePredicate's 4th
      # alternative, and archetypePredicate/nodePredicate's bare-code
      # forms both take the same optional SYM_COMMA suffix - so rather
      # than dispatch to three separate rules, the bracket content is
      # parsed as one predicate-expression grammar (bare code/archetype-id/
      # parameter, or a path comparison, combined with AND/OR - same
      # precedence-climbing shape as whereExpr/containsExpr).
      def parse_path_predicate
        expect(:left_bracket)
        predicate = parse_predicate_or
        expect(:right_bracket)
        predicate
      end

      # nodePredicate : ... | nodePredicate OR nodePredicate ;
      def parse_predicate_or
        left = parse_predicate_and
        left = Model::PredicateOr.new(left: left, right: parse_predicate_and) while match(:or)
        left
      end

      # nodePredicate : ... | nodePredicate AND nodePredicate ;
      def parse_predicate_and
        left = parse_predicate_primary
        left = Model::PredicateAnd.new(left: left, right: parse_predicate_primary) while match(:and)
        left
      end

      # archetypePredicate : ARCHETYPE_HRID (SYM_COMMA ...)? | PARAMETER ;
      # nodePredicate : (ID_CODE | AT_CODE) (SYM_COMMA ...)? | ARCHETYPE_HRID (SYM_COMMA ...)? | PARAMETER
      #               | objectPath COMPARISON_OPERATOR pathPredicateOperand | objectPath MATCHES CONTAINED_REGEX ;
      # objectPath MATCHES CONTAINED_REGEX needs a lexer token this gem
      # doesn't implement yet (deferred, same as elsewhere).
      def parse_predicate_primary
        return parse_archetype_predicate if check(:archetype_hrid)
        return parse_code_predicate if check(:at_code) || check(:id_code)
        return Model::Parameter.new(name: advance.value) if check(:parameter)

        parse_standard_predicate
      end

      def parse_archetype_predicate
        archetype_id = expect(:archetype_hrid).value
        value = match(:comma) ? parse_node_predicate_value : nil
        Model::ArchetypePredicate.new(archetype_id: archetype_id, value: value)
      end

      def parse_code_predicate
        code = advance.value
        value = match(:comma) ? parse_node_predicate_value : nil
        Model::NodePredicate.new(code: code, value: value)
      end

      # The SYM_COMMA suffix's value set: STRING | PARAMETER | TERM_CODE | AT_CODE | ID_CODE.
      # TERM_CODE needs a lexer token this gem doesn't implement yet
      # (deferred, same as elsewhere) and is not supported here.
      def parse_node_predicate_value
        return Model::Parameter.new(name: advance.value) if check(:parameter)
        return advance.value if check(:string) || check(:at_code) || check(:id_code)

        raise error("expected a string, parameter, at-code or id-code after ',', got #{describe(peek)}")
      end

      # standardPredicate : objectPath COMPARISON_OPERATOR pathPredicateOperand ;
      def parse_standard_predicate
        path = parse_object_path
        operator = expect(:comparison_operator).value
        Model::StandardPredicate.new(path: path, operator: operator, operand: parse_path_predicate_operand)
      end

      # pathPredicateOperand : primitive | objectPath | PARAMETER | ID_CODE | AT_CODE ;
      # The bare ID_CODE/AT_CODE alternatives (distinct from an objectPath
      # that happens to start with one - objectPath's pathPart is always
      # IDENTIFIER, never a code) aren't needed by any current example and
      # are deferred.
      def parse_path_predicate_operand
        return Model::Parameter.new(name: advance.value) if check(:parameter)
        return parse_primitive if primitive_ahead?
        return parse_object_path if check(:identifier)

        raise error("expected a parameter, a literal value or a path, got #{describe(peek)}")
      end

      # objectPath : pathPart (SYM_SLASH pathPart)* ;
      def parse_object_path
        parts = [parse_path_part]
        parts << parse_path_part while match(:slash)
        Model::ObjectPath.new(segments: parts)
      end

      # pathPart : IDENTIFIER pathPredicate? ;
      def parse_path_part
        attribute = expect(:identifier).value
        predicate = check(:left_bracket) ? parse_path_predicate : nil
        Model::PathPart.new(attribute: attribute, predicate: predicate)
      end

      # identifiedPath : IDENTIFIER pathPredicate? (SYM_SLASH objectPath)? ;
      def parse_identified_path
        variable = expect(:identifier).value
        predicate = check(:left_bracket) ? parse_path_predicate : nil
        path = match(:slash) ? parse_object_path : nil
        Model::IdentifiedPath.new(variable: variable, predicate: predicate, path: path)
      end

      # whereClause : WHERE whereExpr ;
      def parse_where_clause
        expect(:where)
        Model::WhereClause.new(expression: parse_or_expr)
      end

      # whereExpr's left-recursive AND/OR/NOT alternatives, rewritten as
      # standard precedence climbing (NOT tightest, then AND, then OR -
      # the usual boolean-operator precedence, matching how the official
      # examples read without needing extra parens).
      def parse_or_expr
        left = parse_and_expr
        left = Model::OrExpr.new(left: left, right: parse_and_expr) while match(:or)
        left
      end

      def parse_and_expr
        left = parse_not_expr
        left = Model::AndExpr.new(left: left, right: parse_not_expr) while match(:and)
        left
      end

      # whereExpr : ... | NOT whereExpr | ... ;
      def parse_not_expr
        return Model::NotExpr.new(operand: parse_not_expr) if match(:not)

        parse_where_primary
      end

      # whereExpr : ... | SYM_LEFT_PAREN whereExpr SYM_RIGHT_PAREN ;
      # (identifiedExpr's own, narrower "( identifiedExpr )" alternative is
      # already covered by this, since identifiedExpr is one kind of
      # whereExpr.)
      def parse_where_primary
        return parse_identified_expr unless match(:left_paren)

        expr = parse_or_expr
        expect(:right_paren)
        expr
      end

      # identifiedExpr : EXISTS identifiedPath
      #                | identifiedPath COMPARISON_OPERATOR terminal
      #                | identifiedPath LIKE likeOperand
      #                | identifiedPath MATCHES matchesOperand ;
      # The functionCall-on-the-left comparison alternative is added by M8.
      def parse_identified_expr
        return Model::ExistsExpr.new(path: parse_identified_path) if match(:exists)

        path = parse_identified_path
        if check(:comparison_operator)
          Model::Comparison.new(left: path, operator: advance.value, right: parse_terminal)
        elsif match(:like)
          Model::LikeExpr.new(path: path, operand: parse_like_operand)
        elsif match(:matches)
          Model::MatchesExpr.new(path: path, operand: parse_matches_operand)
        else
          raise error("expected a comparison operator, LIKE or MATCHES, got #{describe(peek)}")
        end
      end

      # terminal : primitive | PARAMETER | identifiedPath | functionCall ;
      def parse_terminal
        return Model::Parameter.new(name: advance.value) if check(:parameter)
        return parse_function_call if function_call_ahead?
        return parse_primitive if primitive_ahead?
        return parse_identified_path if check(:identifier)

        raise error("expected a value, parameter, path or function call, got #{describe(peek)}")
      end

      # likeOperand : STRING | PARAMETER ;
      def parse_like_operand
        return Model::Parameter.new(name: advance.value) if check(:parameter)

        Model::Literal.new(value: expect(:string).value)
      end

      # matchesOperand : SYM_LEFT_CURLY valueListItem (SYM_COMMA valueListItem)* SYM_RIGHT_CURLY
      #                | terminologyFunction
      #                | SYM_LEFT_CURLY URI SYM_RIGHT_CURLY ;
      def parse_matches_operand
        return parse_terminology_function if check(:terminology)

        expect(:left_curly)
        operand = if check(:uri)
                    Model::UriRef.new(uri: advance.value)
                  else
                    items = [parse_value_list_item]
                    items << parse_value_list_item while match(:comma)
                    Model::MatchesValueList.new(items: items)
                  end
        expect(:right_curly)
        operand
      end

      # valueListItem : primitive | PARAMETER | terminologyFunction ;
      def parse_value_list_item
        return Model::Parameter.new(name: advance.value) if check(:parameter)
        return parse_terminology_function if check(:terminology)
        return parse_primitive if primitive_ahead?

        raise error("expected a literal value, a parameter or TERMINOLOGY(...) in a MATCHES value list, " \
                     "got #{describe(peek)}")
      end

      # terminologyFunction : TERMINOLOGY SYM_LEFT_PAREN STRING SYM_COMMA STRING SYM_COMMA STRING SYM_RIGHT_PAREN ;
      def parse_terminology_function
        expect(:terminology)
        expect(:left_paren)
        args = [expect(:string).value]
        2.times do
          expect(:comma)
          args << expect(:string).value
        end
        expect(:right_paren)
        Model::TerminologyFunctionCall.new(args: args)
      end

      # aggregateFunctionCall : name=COUNT SYM_LEFT_PAREN (DISTINCT? identifiedPath | SYM_ASTERISK) SYM_RIGHT_PAREN
      #                       | name=(MIN | MAX | SUM | AVG) SYM_LEFT_PAREN identifiedPath SYM_RIGHT_PAREN ;
      def parse_aggregate_function_call
        name = advance.type
        expect(:left_paren)
        if name == :count && check(:asterisk)
          advance
          path = nil
          distinct = false
        else
          distinct = name == :count && match(:distinct)
          path = parse_identified_path
        end
        expect(:right_paren)
        Model::AggregateFunctionCall.new(name: name, path: path, distinct: distinct)
      end

      def aggregate_function_ahead?
        AGGREGATE_FUNCTION_TYPES.include?(peek.type) && peek(1).type == :left_paren
      end

      # functionCall : terminologyFunction
      #              | name=(STRING_FUNCTION_ID | NUMERIC_FUNCTION_ID | DATE_TIME_FUNCTION_ID | IDENTIFIER)
      #                SYM_LEFT_PAREN (terminal (SYM_COMMA terminal)*)? SYM_RIGHT_PAREN ;
      # The functionCall-on-the-left-of-a-comparison identifiedExpr
      # alternative isn't needed by any example and is deferred.
      def parse_function_call
        return parse_terminology_function if check(:terminology)

        name = advance.value
        expect(:left_paren)
        args = []
        unless check(:right_paren)
          args << parse_terminal
          args << parse_terminal while match(:comma)
        end
        expect(:right_paren)
        Model::FunctionCall.new(name: name, arguments: args)
      end

      def function_call_ahead?
        return true if check(:terminology)

        (FUNCTION_NAME_TYPES.include?(peek.type) || check(:identifier)) && peek(1).type == :left_paren
      end

      # orderByClause : ORDER BY orderByExpr (SYM_COMMA orderByExpr)* ;
      def parse_order_by_clause
        expect(:order)
        expect(:by)
        items = [parse_order_by_expr]
        items << parse_order_by_expr while match(:comma)
        Model::OrderByClause.new(items: items)
      end

      # orderByExpr : identifiedPath order=(DESCENDING|DESC|ASCENDING|ASC)? ;
      def parse_order_by_expr
        path = parse_identified_path
        direction = :asc
        if check(:desc) || check(:descending) || check(:asc) || check(:ascending)
          direction = DESCENDING_DIRECTIONS.include?(advance.type) ? :desc : :asc
        end
        Model::OrderByItem.new(path: path, direction: direction)
      end

      # limitClause : LIMIT limit=INTEGER (OFFSET offset=INTEGER)? ;
      def parse_limit_clause
        expect(:limit)
        limit = expect(:integer).value
        offset = match(:offset) ? expect(:integer).value : 0
        Model::LimitClause.new(limit: limit, offset: offset)
      end

      def primitive_ahead?
        PRIMITIVE_TOKEN_TYPES.include?(peek.type)
      end

      # primitive : STRING | numericPrimitive | DATE | TIME | DATETIME | BOOLEAN | NULL ;
      def parse_primitive
        token = advance
        Model::Literal.new(value: token.type == :null ? nil : token.value)
      end

      # --- token stream helpers ---

      def peek(offset = 0)
        @tokens[@pos + offset] || @tokens.last
      end

      def check(type)
        peek.type == type
      end

      def advance
        token = peek
        @pos += 1 unless token.type == :eof
        token
      end

      def match(type)
        return false unless check(type)

        advance
        true
      end

      def expect(type)
        return advance if check(type)

        raise error("expected #{type.to_s.upcase}, got #{describe(peek)}")
      end

      def describe(token)
        token.type == :eof ? 'end of input' : "#{token.type} #{token.value.inspect}"
      end

      def error(message)
        ParseError.new(message, line: peek.line, column: peek.column)
      end
    end
  end
end
