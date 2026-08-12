module OpenEHR
  module AQL
    # A single row-candidate produced while walking the FROM clause's
    # containment tree: the Dataset::EHRRecord it came from (for "e/..."
    # root paths) plus the RM objects bound to each FROM variable so far
    # (e.g. {"c" => a_composition, "o" => an_observation}).
    Binding = Struct.new(:ehr_record, :variables, keyword_init: true) do
      def [](name)
        variables.fetch(name) { raise SemanticError, "unbound variable: #{name.inspect}" }
      end
    end
  end
end
