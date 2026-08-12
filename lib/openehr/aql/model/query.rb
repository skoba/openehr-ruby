module OpenEHR
  module AQL
    module Model
      # The parsed, immutable representation of an AQL selectQuery.
      # Clauses that a milestone hasn't implemented yet are nil.
      class Query
        attr_reader :select_clause, :from_clause, :where_clause

        def initialize(select_clause:, from_clause:, where_clause: nil)
          @select_clause = select_clause
          @from_clause = from_clause
          @where_clause = where_clause
          freeze
        end
      end
    end
  end
end
