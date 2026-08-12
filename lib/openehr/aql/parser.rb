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
      # WHERE/ORDER BY/LIMIT are added by M5/M6; until then, any token
      # left over after the FROM clause is a ParseError.
      def parse_select_query
        select_clause = parse_select_clause
        from_clause = parse_from_clause
        expect(:eof)
        Model::Query.new(select_clause: select_clause, from_clause: from_clause)
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
