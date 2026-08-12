require_relative 'binding'

module OpenEHR
  module AQL
    # Walks a FromClause's containment tree against a Dataset, producing
    # one Binding per match. E2 scope: a single, unpredicated
    # ClassExpression matched directly against each EHR record's
    # compositions (e.g. "FROM COMPOSITION c"). EHR roots, CONTAINS
    # nesting, predicates and boolean grouping are added by later engine
    # milestones.
    class ContainsResolver
      def initialize(from_clause, dataset)
        @root = from_clause.containment
        @dataset = dataset
      end

      def each_binding
        return enum_for(:each_binding) unless block_given?

        @dataset.each_ehr do |ehr_record|
          resolve(@root, ehr_record).each { |variables| yield Binding.new(ehr_record: ehr_record, variables: variables) }
        end
      end

      private

      def resolve(node, ehr_record)
        case node
        when Model::ClassExpression
          resolve_class_expression(node, ehr_record)
        else
          raise ExecutionError, "cannot execute a #{node.class} containment yet"
        end
      end

      def resolve_class_expression(class_expression, ehr_record)
        ehr_record.compositions
                  .select { |composition| OpenEHR::RM.subtype_of?(composition, class_expression.class_name) }
                  .map { |composition| variables_for(class_expression, composition) }
      end

      def variables_for(class_expression, matched)
        return {} unless class_expression.variable

        { class_expression.variable => matched }
      end
    end
  end
end
