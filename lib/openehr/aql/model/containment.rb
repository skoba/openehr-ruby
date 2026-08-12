module OpenEHR
  module AQL
    module Model
      # containsExpr's "classExprOperand (NOT? CONTAINS containsExpr)?"
      # shape: a right-recursive chain (A CONTAINS B CONTAINS C ...), so
      # `child` is itself a ClassExpression, another Containment, or (from
      # M7) a ContainmentAnd/ContainmentOr grouping of sibling branches.
      class Containment
        attr_reader :parent, :child, :negated
        alias negated? negated

        def initialize(parent:, child:, negated: false)
          @parent = parent
          @child = child
          @negated = negated
          freeze
        end
      end

      # containsExpr : ... | containsExpr AND containsExpr | ... ;
      # Groups sibling containment branches that must ALL be present
      # under the same parent, e.g. "CONTAINS (OBSERVATION o1 AND OBSERVATION o2)".
      class ContainmentAnd
        attr_reader :left, :right

        def initialize(left:, right:)
          @left = left
          @right = right
          freeze
        end
      end

      # containsExpr : ... | containsExpr OR containsExpr | ... ;
      class ContainmentOr
        attr_reader :left, :right

        def initialize(left:, right:)
          @left = left
          @right = right
          freeze
        end
      end
    end
  end
end
