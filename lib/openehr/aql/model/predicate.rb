module OpenEHR
  module AQL
    module Model
      # standardPredicate : objectPath COMPARISON_OPERATOR pathPredicateOperand ;
      # archetypePredicate/nodePredicate (M3) are separate pathPredicate
      # alternatives, not yet modelled here.
      class StandardPredicate
        attr_reader :path, :operator, :operand

        def initialize(path:, operator:, operand:)
          @path = path
          @operator = operator
          @operand = operand
          freeze
        end
      end

      # archetypePredicate : ARCHETYPE_HRID | PARAMETER ;
      # The PARAMETER alternative (a whole predicate substituted at
      # execution time, e.g. "[$archetypeId]") isn't needed by any current
      # milestone and is deferred.
      class ArchetypePredicate
        attr_reader :archetype_id

        def initialize(archetype_id:)
          @archetype_id = archetype_id
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
