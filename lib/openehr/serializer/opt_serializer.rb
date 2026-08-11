require 'json'
require_relative 'base'

module OpenEHR
  module Serializer
    class OPTSerializer < BaseSerializer
      def initialize(opt, format:)
        @opt = OpenEHR::Parser::OPTParser.new(opt).parse
        @format = format
      end

      def name
        @opt.definition.archetype_id.concept_name
      end

      # Template-level metadata, as JSON. An operational template
      # carries constraints, not instance data - it has no composer or
      # territory to report - so this is the concept/ids/language the
      # OPT actually captures, rather than a simulated RM COMPOSITION.
      def header
        JSON.generate(
          'concept' => @opt.concept,
          'archetype_id' => @opt.definition.archetype_id.value,
          'template_id' => @opt.template_id.value,
          'language' => @opt.original_language.code_string
        )
      end

      # The root archetype's context/content constraint subtrees (what
      # the template actually constrains for those attributes), as
      # JSON via JSONSerializer - the same generic walker
      # RMJSONSerializer uses for RM instances.
      def context
        attribute_json('context')
      end

      def content
        attribute_json('content')
      end

      private

      def attribute_json(rm_attribute_name)
        attribute = @opt.definition.attributes.find { |a| a.rm_attribute_name == rm_attribute_name }
        JSONSerializer.new(attribute).serialize
      end
    end
  end
end
