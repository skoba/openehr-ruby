module OpenEHR
  module AQL
    module Model
      # whereClause : WHERE whereExpr ;
      class WhereClause
        attr_reader :expression

        def initialize(expression:)
          @expression = expression
          freeze
        end
      end

      # whereExpr : ... | whereExpr AND whereExpr | ... ;
      class AndExpr
        attr_reader :left, :right

        def initialize(left:, right:)
          @left = left
          @right = right
          freeze
        end
      end

      # whereExpr : ... | whereExpr OR whereExpr | ... ;
      class OrExpr
        attr_reader :left, :right

        def initialize(left:, right:)
          @left = left
          @right = right
          freeze
        end
      end

      # whereExpr : ... | NOT whereExpr | ... ;
      class NotExpr
        attr_reader :operand

        def initialize(operand:)
          @operand = operand
          freeze
        end
      end

      # identifiedExpr : identifiedPath COMPARISON_OPERATOR terminal | functionCall COMPARISON_OPERATOR terminal ;
      # The functionCall-on-the-left alternative is added by M8.
      class Comparison
        attr_reader :left, :operator, :right

        def initialize(left:, operator:, right:)
          @left = left
          @operator = operator
          @right = right
          freeze
        end
      end

      # identifiedExpr : EXISTS identifiedPath | ... ;
      class ExistsExpr
        attr_reader :path

        def initialize(path:)
          @path = path
          freeze
        end
      end

      # identifiedExpr : identifiedPath LIKE likeOperand | ... ;
      class LikeExpr
        attr_reader :path, :operand

        def initialize(path:, operand:)
          @path = path
          @operand = operand
          freeze
        end
      end

      # identifiedExpr : identifiedPath MATCHES matchesOperand | ... ;
      class MatchesExpr
        attr_reader :path, :operand

        def initialize(path:, operand:)
          @path = path
          @operand = operand
          freeze
        end
      end

      # matchesOperand's value-list alternative:
      #   SYM_LEFT_CURLY valueListItem (SYM_COMMA valueListItem)* SYM_RIGHT_CURLY
      # The terminologyFunction-item and bare-URI alternatives need a URI
      # lexer token that doesn't exist yet, and are deferred.
      class MatchesValueList
        attr_reader :items

        def initialize(items:)
          @items = items.freeze
          freeze
        end
      end
    end
  end
end
