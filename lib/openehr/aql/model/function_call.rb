module OpenEHR
  module AQL
    module Model
      # aggregateFunctionCall : name=COUNT SYM_LEFT_PAREN (DISTINCT? identifiedPath | SYM_ASTERISK) SYM_RIGHT_PAREN
      #                       | name=(MIN | MAX | SUM | AVG) SYM_LEFT_PAREN identifiedPath SYM_RIGHT_PAREN ;
      # `path` is nil only for the COUNT(*) form; `distinct` is only ever
      # true for COUNT (the grammar doesn't allow DISTINCT on MIN/MAX/SUM/AVG).
      class AggregateFunctionCall
        attr_reader :name, :path, :distinct

        def initialize(name:, path: nil, distinct: false)
          @name = name
          @path = path
          @distinct = distinct
          freeze
        end
      end

      # functionCall : terminologyFunction
      #              | name=(STRING_FUNCTION_ID | NUMERIC_FUNCTION_ID | DATE_TIME_FUNCTION_ID | IDENTIFIER)
      #                SYM_LEFT_PAREN (terminal (SYM_COMMA terminal)*)? SYM_RIGHT_PAREN ;
      class FunctionCall
        attr_reader :name, :arguments

        def initialize(name:, arguments: [])
          @name = name
          @arguments = arguments.freeze
          freeze
        end
      end

      # terminologyFunction : TERMINOLOGY SYM_LEFT_PAREN STRING SYM_COMMA STRING SYM_COMMA STRING SYM_RIGHT_PAREN ;
      # The grammar doesn't name the three STRING arguments (their meaning
      # - expand-operation, terminology id, value-set expression - is
      # spec prose, not grammar), so they're kept as a plain positional list.
      class TerminologyFunctionCall
        attr_reader :args

        def initialize(args:)
          @args = args.freeze
          freeze
        end
      end

      # matchesOperand's bare-URI alternative: SYM_LEFT_CURLY URI SYM_RIGHT_CURLY ;
      class UriRef
        attr_reader :uri

        def initialize(uri:)
          @uri = uri
          freeze
        end
      end
    end
  end
end
