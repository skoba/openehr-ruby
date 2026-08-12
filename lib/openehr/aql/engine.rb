require_relative 'engine/binding'
require_relative 'engine/contains_resolver'
require_relative 'engine/path_evaluator'
require_relative 'result_set'

module OpenEHR
  module AQL
    # Orchestrates one Query execution against a Dataset. E2 scope: the
    # CONTAINS -> SELECT slice only (ContainsResolver#each_binding, then
    # PathEvaluator over each select column). WHERE, ORDER BY, LIMIT/OFFSET
    # and DISTINCT are spliced into this pipeline by later engine
    # milestones - see the project plan's engine.rb file-layout comment
    # for the full intended pipeline order.
    class Engine
      def initialize(query)
        @query = query
      end

      def execute(dataset, params: {})
        columns = @query.select_clause.columns
        rows = ContainsResolver.new(@query.from_clause, Dataset.wrap(dataset)).each_binding.map do |binding|
          columns.map { |column| PathEvaluator.evaluate(column.expression, binding) }
        end
        ResultSet.new(columns: columns.map { |column| column_name(column) }, rows: rows)
      end

      private

      def column_name(column)
        return column.alias_name if column.alias_name

        expression = column.expression
        expression.is_a?(Model::IdentifiedPath) ? expression.variable : expression.class.name
      end
    end
  end
end
