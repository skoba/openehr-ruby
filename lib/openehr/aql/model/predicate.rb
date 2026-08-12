module OpenEHR
  module AQL
    module Model
      # standardPredicate : objectPath COMPARISON_OPERATOR pathPredicateOperand ;
      # (nodePredicate's 4th alternative has this identical shape - see
      # Parser#parse_standard_predicate's comment.)
      class StandardPredicate
        attr_reader :path, :operator, :operand

        def initialize(path:, operator:, operand:)
          @path = path
          @operator = operator
          @operand = operand
          freeze
        end
      end

      # archetypePredicate : ARCHETYPE_HRID (SYM_COMMA (STRING | PARAMETER | TERM_CODE | AT_CODE | ID_CODE))? | PARAMETER ;
      # `value` is the optional SYM_COMMA suffix: a raw String (for
      # STRING/AT_CODE/ID_CODE) or a Parameter. The bare-PARAMETER
      # alternative (a whole predicate substituted at execution time,
      # e.g. "[$archetypeId]") isn't needed by any current example and is
      # deferred - see Parser#parse_predicate_primary.
      class ArchetypePredicate
        attr_reader :archetype_id, :value

        def initialize(archetype_id:, value: nil)
          @archetype_id = archetype_id
          @value = value
          freeze
        end
      end

      # nodePredicate : (ID_CODE | AT_CODE) (SYM_COMMA (STRING | PARAMETER | TERM_CODE | AT_CODE | ID_CODE))? | ... ;
      # `value` is the optional SYM_COMMA suffix, same shape as
      # ArchetypePredicate#value.
      class NodePredicate
        attr_reader :code, :value

        def initialize(code:, value: nil)
          @code = code
          @value = value
          freeze
        end
      end

      # nodePredicate : ... | nodePredicate AND nodePredicate | ... ;
      # Combines any pathPredicate-body primaries (ArchetypePredicate,
      # NodePredicate, Parameter, StandardPredicate). AND binds tighter
      # than OR, same precedence-climbing convention used for whereExpr
      # (M5) and containsExpr (M7).
      class PredicateAnd
        attr_reader :left, :right

        def initialize(left:, right:)
          @left = left
          @right = right
          freeze
        end
      end

      # nodePredicate : ... | nodePredicate OR nodePredicate ;
      class PredicateOr
        attr_reader :left, :right

        def initialize(left:, right:)
          @left = left
          @right = right
          freeze
        end
      end

      # PARAMETER: '$' IDENTIFIER_CHAR ;
      class Parameter
        attr_reader :name

        def initialize(name:)
          @name = name
          freeze
        end
      end
    end
  end
end
