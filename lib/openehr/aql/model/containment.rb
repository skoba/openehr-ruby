module OpenEHR
  module AQL
    module Model
      # containsExpr's "classExprOperand CONTAINS containsExpr" shape: a
      # right-recursive chain (A CONTAINS B CONTAINS C ...), so `child` is
      # itself either a leaf ClassExpression or another Containment.
      # AND/OR grouping, parens and NOT CONTAINS are added by M7.
      class Containment
        attr_reader :parent, :child

        def initialize(parent:, child:)
          @parent = parent
          @child = child
          freeze
        end
      end
    end
  end
end
