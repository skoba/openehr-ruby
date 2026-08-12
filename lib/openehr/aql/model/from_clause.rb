module OpenEHR
  module AQL
    module Model
      # fromClause : FROM fromExpr ; fromExpr : containsExpr ;
      # `containment` holds the root of the containsExpr tree. Until M3/M7
      # add archetype/node predicates and CONTAINS nesting, it is always a
      # single, unpredicated ClassExpression.
      class FromClause
        attr_reader :containment

        def initialize(containment:)
          @containment = containment
          freeze
        end
      end

      # classExprOperand's #classExpression alternative:
      #   IDENTIFIER variable=IDENTIFIER? pathPredicate?
      # A bare RM class name (e.g. "COMPOSITION"), optionally bound to a
      # variable and constrained by a predicate. Until M3 adds
      # archetypePredicate/nodePredicate, `predicate` can only be a
      # StandardPredicate (or nil).
      class ClassExpression
        attr_reader :class_name, :variable, :predicate

        def initialize(class_name:, variable: nil, predicate: nil)
          @class_name = class_name
          @variable = variable
          @predicate = predicate
          freeze
        end
      end
    end
  end
end
