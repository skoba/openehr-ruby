module OpenEHR
  module AQL
    module Model
      # selectClause : SELECT DISTINCT? top? selectExpr (SYM_COMMA selectExpr)* ;
      class SelectClause
        attr_reader :columns, :distinct, :top
        alias distinct? distinct

        def initialize(columns:, distinct: false, top: nil)
          @columns = columns.freeze
          @distinct = distinct
          @top = top
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
