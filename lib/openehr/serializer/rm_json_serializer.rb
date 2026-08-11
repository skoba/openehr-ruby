require 'json'
require 'set'

module OpenEHR
  module Serializer
    # Canonical JSON for an RM instance graph: a generic reflection
    # walker (not a hand-written serializer per RM class), tagging
    # each object with a "_type" discriminator (via
    # OpenEHR::RM.type_name_of) and recursing into every non-nil
    # instance variable except @parent (PATHABLE's back-reference,
    # which would otherwise make every subtree cyclic). A defensive
    # visited-object guard covers any other unexpected back-reference.
    class RMJSONSerializer
      EXCLUDED_IVARS = [:@parent].freeze

      def initialize(rm_instance)
        @rm_instance = rm_instance
      end

      def serialize
        JSON.generate(to_value(@rm_instance, Set.new.compare_by_identity))
      end

      private

      def to_value(value, seen)
        case value
        when nil, true, false, Numeric, String
          value
        when Array
          value.map { |v| to_value(v, seen) }
        when Hash
          value.each_with_object({}) { |(k, v), h| h[k.to_s] = to_value(v, seen) }
        else
          object_value(value, seen)
        end
      end

      def object_value(value, seen)
        return nil if seen.include?(value)

        seen << value
        hash = {'_type' => OpenEHR::RM.type_name_of(value)}
        (value.instance_variables - EXCLUDED_IVARS).each do |ivar|
          field = value.instance_variable_get(ivar)
          next if field.nil?

          hash[ivar.to_s.delete_prefix('@')] = to_value(field, seen)
        end
        hash
      end
    end

    # RMJSONSerializer's reflection walker has no RM-specific logic
    # (it derives "_type" from each object's own class and excludes
    # only the PATHABLE/ArchetypeConstraint @parent back-reference),
    # so the same class already serializes AOM constraint trees
    # (CComplexObject, CAttribute, ...) correctly. Exposed under this
    # name for that use.
    JSONSerializer = RMJSONSerializer
  end
end
