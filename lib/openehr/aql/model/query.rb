module OpenEHR
  module AQL
    module Model
      # The parsed, immutable representation of an AQL selectQuery.
      # Clauses that a milestone hasn't implemented yet are nil.
      class Query
        attr_reader :select_clause, :from_clause, :where_clause, :order_by_clause, :limit_clause

        def initialize(select_clause:, from_clause:, where_clause: nil, order_by_clause: nil, limit_clause: nil)
          @select_clause = select_clause
          @from_clause = from_clause
          @where_clause = where_clause
          @order_by_clause = order_by_clause
          @limit_clause = limit_clause
          freeze
        end

        def execute(dataset, params: {})
          OpenEHR::AQL::Engine.new(self).execute(dataset, params: params)
        end
      end
    end
  end
end
