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
