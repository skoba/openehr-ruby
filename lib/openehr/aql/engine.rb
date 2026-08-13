require_relative 'engine/binding'
require_relative 'engine/contains_resolver'
require_relative 'engine/path_evaluator'
require_relative 'engine/predicate_evaluator'
require_relative 'result_set'

module OpenEHR
  module AQL
    # Orchestrates one Query execution against a Dataset, in the order
    # CONTAINS -> WHERE -> ORDER BY -> SELECT -> DISTINCT -> TOP/LIMIT/OFFSET.
    #
    # A SELECT clause made entirely of aggregate columns
    # (Model::AggregateFunctionCall) collapses the whole (post-WHERE)
    # binding set into a single summary row instead - ORDER BY/DISTINCT/
    # TOP/LIMIT don't apply to it, matching plain SQL aggregate-without-
    # GROUP-BY semantics. A SELECT mixing aggregate and non-aggregate
    # columns implicitly groups by every non-aggregate column's value
    # (the standard SQL reading when no explicit GROUP BY is given) -
    # zero surviving bindings therefore means zero groups/rows, unlike
    # the all-aggregate case's single row of aggregate defaults. Generic
    # (non-aggregate) function calls are not yet supported.
    class Engine
      def initialize(query)
        @query = query
      end

      def execute(dataset, params: {})
        bindings = ContainsResolver.new(@query.from_clause, Dataset.wrap(dataset), params: params).each_binding
                                    .select { |binding| where_matches?(binding, params) }
        rows = aggregate_query? ? aggregate_rows(bindings) : select_rows(bindings)
        ResultSet.new(columns: @query.select_clause.columns.map { |column| column_name(column) }, rows: rows)
      end

      private

      def where_matches?(binding, params)
        PredicateEvaluator.matches?(@query.where_clause&.expression, binding, params)
      end

      def select_rows(bindings)
        rows = project(order(bindings))
        rows = rows.uniq if @query.select_clause.distinct
        apply_limit(apply_top(rows))
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

      # TOP is deprecated in favour of LIMIT (still grammatical); combined
      # with LIMIT it has no defined meaning, so raise rather than guess.
      def apply_top(rows)
        top = @query.select_clause.top
        return rows unless top
        raise ExecutionError, 'combining SELECT TOP with LIMIT is not supported - use LIMIT alone' if @query.limit_clause

        top.direction == :backward ? rows.last(top.count) : rows.take(top.count)
      end

      def aggregate_query?
        @query.select_clause.columns.any? { |column| column.expression.is_a?(Model::AggregateFunctionCall) }
      end

      def all_aggregate_columns?
        @query.select_clause.columns.all? { |column| column.expression.is_a?(Model::AggregateFunctionCall) }
      end

      # All-aggregate columns collapse every surviving binding into one
      # summary row, same as plain SQL aggregate-without-GROUP-BY. A mix
      # groups by the non-aggregate columns' values instead - every
      # binding in a group shares those values by construction, so the
      # group's first binding is as good as any for reading them back.
      def aggregate_rows(bindings)
        return [aggregate_row(bindings)] if all_aggregate_columns?

        bindings.group_by { |binding| group_key(binding) }.map { |_key, group| aggregate_row(group) }
      end

      def group_key(binding)
        @query.select_clause.columns.map do |column|
          next nil if column.expression.is_a?(Model::AggregateFunctionCall)

          PathEvaluator.evaluate(column.expression, binding)
        end
      end

      def aggregate_row(bindings)
        @query.select_clause.columns.map do |column|
          call = column.expression
          call.is_a?(Model::AggregateFunctionCall) ? evaluate_aggregate(call, bindings) : PathEvaluator.evaluate(call, bindings.first)
        end
      end

      def evaluate_aggregate(call, bindings)
        return bindings.size if call.name == :count && call.path.nil?

        values = bindings.map { |binding| PathEvaluator.evaluate(call.path, binding) }.compact
        values = values.uniq if call.distinct

        case call.name
        when :count then values.size
        when :min then values.min
        when :max then values.max
        when :sum then values.empty? ? nil : values.sum
        when :avg then values.empty? ? nil : values.sum.fdiv(values.size)
        else raise ExecutionError, "cannot evaluate a #{call.name.inspect} aggregate function yet"
        end
      end

      def column_name(column)
        return column.alias_name if column.alias_name

        expression = column.expression
        expression.is_a?(Model::IdentifiedPath) ? expression.variable : expression.class.name
      end
    end
  end
end
