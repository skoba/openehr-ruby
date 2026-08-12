require_relative 'engine/binding'
require_relative 'engine/contains_resolver'
require_relative 'engine/path_evaluator'
require_relative 'engine/predicate_evaluator'
require_relative 'result_set'

module OpenEHR
  module AQL
    # Orchestrates one Query execution against a Dataset, in the order
    # CONTAINS -> WHERE -> ORDER BY -> SELECT -> DISTINCT -> LIMIT/OFFSET.
    # Boolean containment execution (AND/OR/NOT CONTAINS) and functions
    # are added by later engine milestones.
    class Engine
      def initialize(query)
        @query = query
      end

      def execute(dataset, params: {})
        bindings = ContainsResolver.new(@query.from_clause, Dataset.wrap(dataset)).each_binding
                                    .select { |binding| where_matches?(binding, params) }
        bindings = order(bindings)
        rows = project(bindings)
        rows = rows.uniq if @query.select_clause.distinct
        rows = apply_limit(rows)
        ResultSet.new(columns: @query.select_clause.columns.map { |column| column_name(column) }, rows: rows)
      end

      private

      def where_matches?(binding, params)
        PredicateEvaluator.matches?(@query.where_clause&.expression, binding, params)
      end

      def order(bindings)
        order_by = @query.order_by_clause
        return bindings unless order_by

        bindings.sort { |a, b| compare_bindings(a, b, order_by.items) }
      end

      def compare_bindings(a, b, order_by_items)
        order_by_items.each do |item|
          cmp = compare_values(PathEvaluator.evaluate(item.path, a), PathEvaluator.evaluate(item.path, b))
          cmp = -cmp if item.direction == :desc
          return cmp unless cmp.zero?
        end
        0
      end

      # nil (an absent path) sorts after any real value, regardless of
      # ASC/DESC - the usual SQL "NULLS LAST" convention.
      def compare_values(a, b)
        return 0 if a.nil? && b.nil?
        return 1 if a.nil?
        return -1 if b.nil?

        a <=> b
      end

      def project(bindings)
        columns = @query.select_clause.columns
        bindings.map { |binding| columns.map { |column| PathEvaluator.evaluate(column.expression, binding) } }
      end

      def apply_limit(rows)
        limit_clause = @query.limit_clause
        return rows unless limit_clause

        rows.drop(limit_clause.offset).take(limit_clause.limit)
      end

      def column_name(column)
        return column.alias_name if column.alias_name

        expression = column.expression
        expression.is_a?(Model::IdentifiedPath) ? expression.variable : expression.class.name
      end
    end
  end
end
