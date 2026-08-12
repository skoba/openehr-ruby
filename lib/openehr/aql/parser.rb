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
      # ORDER BY/LIMIT are added by M6; until then, any token left over
      # after the WHERE clause (or FROM clause, if there is none) is a
      # ParseError.
      def parse_select_query
        select_clause = parse_select_clause
        from_clause = parse_from_clause
        where_clause = check(:where) ? parse_where_clause : nil
        expect(:eof)
        Model::Query.new(select_clause: select_clause, from_clause: from_clause, where_clause: where_clause)
      end

      PRIMITIVE_TOKEN_TYPES = %i[string integer real sci_integer sci_real boolean null].freeze

      private

      # selectClause : SELECT DISTINCT? top? selectExpr (SYM_COMMA selectExpr)* ;
      def parse_select_clause
        expect(:select)
        columns = [parse_select_expr]
        columns << parse_select_expr while match(:comma)
        Model::SelectClause.new(columns: columns, distinct: false)
      end

      # selectExpr : columnExpr (AS aliasName=IDENTIFIER)? ;
      def parse_select_expr
        expression = parse_column_expr
        alias_name = match(:as) ? expect(:identifier).value : nil
        Model::SelectColumn.new(expression: expression, alias_name: alias_name)
      end

      # columnExpr : identifiedPath | primitive | aggregateFunctionCall | functionCall ;
      def parse_column_expr
        return parse_identified_path if check(:identifier)
        return parse_primitive if primitive_ahead?

        raise error("expected a path or a literal value, got #{describe(peek)}")
      end

      # fromClause : FROM fromExpr ; fromExpr : containsExpr ;
      def parse_from_clause
        expect(:from)
        Model::FromClause.new(containment: parse_contains_expr)
      end

      # containsExpr : classExprOperand (NOT? CONTAINS containsExpr)? | ... ;
      # AND/OR grouping, parens and "NOT CONTAINS" are added by M7; this
      # milestone only implements the right-recursive
      # "A CONTAINS B CONTAINS C ..." chain.
      def parse_contains_expr
        operand = parse_class_expr_operand
        return operand unless match(:contains)

        Model::Containment.new(parent: operand, child: parse_contains_expr)
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
      def parse_path_predicate
        expect(:left_bracket)
        predicate = if check(:archetype_hrid)
                      parse_archetype_predicate
                    elsif check(:at_code) || check(:id_code)
                      parse_node_predicate
                    else
                      parse_standard_predicate
                    end
        expect(:right_bracket)
        predicate
      end

      # archetypePredicate : ARCHETYPE_HRID | PARAMETER ;
      def parse_archetype_predicate
        Model::ArchetypePredicate.new(archetype_id: expect(:archetype_hrid).value)
      end

      # nodePredicate (simple form): (ID_CODE | AT_CODE) ;
      def parse_node_predicate
        Model::NodePredicate.new(code: advance.value)
      end

      # standardPredicate : objectPath COMPARISON_OPERATOR pathPredicateOperand ;
      def parse_standard_predicate
        path = parse_object_path
        operator = expect(:comparison_operator).value
        Model::StandardPredicate.new(path: path, operator: operator, operand: parse_path_predicate_operand)
      end

      # pathPredicateOperand : primitive | objectPath | PARAMETER | ID_CODE | AT_CODE ;
      # The objectPath/ID_CODE/AT_CODE alternatives aren't needed by any
      # M2 example and are deferred.
      def parse_path_predicate_operand
        return Model::Parameter.new(name: advance.value) if check(:parameter)
        return parse_primitive if primitive_ahead?

        raise error("expected a parameter or a literal value, got #{describe(peek)}")
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
      # The leading pathPredicate alternative isn't needed by any M2
      # example and is deferred.
      def parse_identified_path
        variable = expect(:identifier).value
        path = match(:slash) ? parse_object_path : nil
        Model::IdentifiedPath.new(variable: variable, path: path)
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
      # functionCall is added by M8.
      def parse_terminal
        return Model::Parameter.new(name: advance.value) if check(:parameter)
        return parse_primitive if primitive_ahead?
        return parse_identified_path if check(:identifier)

        raise error("expected a value, parameter or path, got #{describe(peek)}")
      end

      # likeOperand : STRING | PARAMETER ;
      def parse_like_operand
        return Model::Parameter.new(name: advance.value) if check(:parameter)

        Model::Literal.new(value: expect(:string).value)
      end

      # matchesOperand : SYM_LEFT_CURLY valueListItem (SYM_COMMA valueListItem)* SYM_RIGHT_CURLY
      #                | terminologyFunction
      #                | SYM_LEFT_CURLY URI SYM_RIGHT_CURLY ;
      # The terminologyFunction and bare-URI alternatives need a URI lexer
      # token that doesn't exist yet, and are deferred.
      def parse_matches_operand
        expect(:left_curly)
        items = [parse_value_list_item]
        items << parse_value_list_item while match(:comma)
        expect(:right_curly)
        Model::MatchesValueList.new(items: items)
      end

      # valueListItem : primitive | PARAMETER | terminologyFunction ;
      # terminologyFunction is added alongside the MATCHES/TERMINOLOGY(...) support.
      def parse_value_list_item
        return Model::Parameter.new(name: advance.value) if check(:parameter)
        return parse_primitive if primitive_ahead?

        raise error("expected a literal value or a parameter in a MATCHES value list, got #{describe(peek)}")
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

      def peek
        @tokens[@pos]
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
