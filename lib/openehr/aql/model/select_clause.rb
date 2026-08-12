module OpenEHR
  module AQL
    module Model
      # selectClause : SELECT DISTINCT? top? selectExpr (SYM_COMMA selectExpr)* ;
      # `distinct` is always false until M6 implements the DISTINCT keyword.
      class SelectClause
        attr_reader :columns, :distinct
        alias distinct? distinct

        def initialize(columns:, distinct: false)
          @columns = columns.freeze
          @distinct = distinct
          freeze
        end
      end

      # selectExpr : columnExpr (AS aliasName=IDENTIFIER)? ;
      class SelectColumn
        attr_reader :expression, :alias_name

        def initialize(expression:, alias_name: nil)
          @expression = expression
          @alias_name = alias_name
          freeze
        end
      end
    end
  end
end
