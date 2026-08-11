require 'rexml/document'
require 'builder'
require_relative 'base'

module OpenEHR
  module Serializer
    class XMLSerializer < BaseSerializer
      def header
        header = ''
        xml = Builder::XmlMarkup.new(:indent => 2, :target => header)
        xml.archetype_id do
          xml.value @archetype.archetype_id.value
        end
        xml.concept @archetype.concept
        xml.original_language do
          xml.terminology_id do
            xml.value @archetype.original_language.terminology_id.value
          end
          xml.code_string @archetype.original_language.code_string
        end
        return header
      end

      def description
        desc = ''
        xml = Builder::XmlMarkup.new(:indent => 2, :target => desc)
        ad = @archetype.description
        if ad
          xml.description do
            ad.original_author.each do |key,value|
              xml.original_author(value,"id"=>key)
            end
            if ad.other_contributors
              ad.other_contributors.each do |co|
                xml.other_contributors co
              end
            end
            xml.lifecycle_state ad.lifecycle_state
            xml.details do
              ad.details.each do |lang, item|
                xml.language do
                  xml.terminology_id do
                    xml.value item.language.terminology_id.value
                  end
                  xml.code_string lang
                end
                xml.purpose item.purpose
                if item.keywords then
                  item.keywords.each do |word|
                    xml.keywords word
                  end
                end
                xml.use item.use if item.use
                xml.misuse item.misuse if item.misuse
                xml.copyright item.copyright if item.copyright
                if ad.other_details
                  ad.other_details.each do |key,value|
                    xml.other_details(value, "id"=>key)
                  end
                end
              end
            end
          end
        end
        return desc
      end

      def definition
        definition = ''
        xml = Builder::XmlMarkup.new(:indent => 2, :target => definition)
        xml.definition do
          emit_c_object_body(xml, @archetype.definition)
        end
        return definition
      end

      def ontology
        ontology = ''
        ao = @archetype.ontology
        xml = Builder::XmlMarkup.new(:indent => 2, :target => ontology)
        xml.ontology do
          xml.specialisation_depth ao.specialisation_depth
          (ao.languages_available || []).each { |lang| xml.languages_available lang }
          (ao.terminologies_available || []).each { |t| xml.terminologies_available t }
          xml.term_definitions do
            ao.term_definitions.each do |lang, terms|
              xml.language lang
              xml.terms do
                terms.each do |code, term|
                  xml.code code
                  xml.items do
                    term.items.each do |key, value|
                      xml.item do
                        xml.key key
                        xml.value value
                      end
                    end
                  end
                end
              end
            end
          end
          emit_term_bindings(xml, ao.term_bindings)
        end
      end

      def merge
        archetype = "<?xml version='1.0' encoding='UTF-8'?>" + NL +
          "<archetype xmlns=\"http://schemas.openehr.org/v1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">" + NL +
          header + description + definition +
          ontology + '</archetype>'
        return archetype
      end

      include OpenEHR::AM::Archetype::ConstraintModel
      Primitive = OpenEHR::AM::Archetype::ConstraintModel::Primitive
      OpenEHRProfile = OpenEHR::AM::OpenEHRProfile

      private

      # Emits a C_OBJECT's own fields (rm_type_name/occurrence/node_id
      # plus, unless any_allowed?, its attributes) directly into the
      # current xml element - used both for the root <definition> and,
      # via emit_child, for every nested C_COMPLEX_OBJECT.
      def emit_c_object_body(xml, node)
        xml.rm_type_name node.rm_type_name
        xml.occurrence { emit_interval(xml, node.occurrences) }
        xml.node_id node.node_id
        return if node.any_allowed?

        node.attributes.each { |a| emit_attribute(xml, a) }
      end

      def emit_interval(xml, interval)
        xml.lower_included interval.lower_included? unless interval.lower_included?.nil?
        xml.upper_included interval.upper_included? unless interval.upper_included?.nil?
        xml.lower_unbounded interval.lower_unbounded?
        xml.upper_unbounded interval.upper_unbounded?
        xml.lower interval.lower
        xml.upper interval.upper
      end

      def emit_attribute(xml, attribute)
        xml.attributes do
          xml.rm_attribute_name attribute.rm_attribute_name
          xml.existence { emit_interval(xml, attribute.existence) } if attribute.existence
          emit_cardinality(xml, attribute.cardinality) if attribute.is_a?(CMultipleAttribute)
          (attribute.children || []).each { |c| emit_child(xml, c) }
        end
      end

      def emit_cardinality(xml, cardinality)
        xml.cardinality do
          next if cardinality.nil?

          xml.is_ordered cardinality.is_ordered?
          xml.is_unique cardinality.is_unique?
          xml.interval { emit_interval(xml, cardinality.interval) } if cardinality.interval
        end
      end

      # Dispatches an attribute's child node, tagging each <children>
      # element with an xsi:type discriminator (the AOM node's class,
      # in openEHR's own naming) since the children of one attribute
      # can be a mix of concrete constraint node types.
      def emit_child(xml, node)
        case node
        when ArchetypeSlot
          xml.children('xsi:type' => 'ARCHETYPE_SLOT') { emit_archetype_slot_body(xml, node) }
        when ArchetypeInternalRef
          xml.children('xsi:type' => 'ARCHETYPE_INTERNAL_REF') { xml.target_path node.target_path }
        when ConstraintRef
          xml.children('xsi:type' => 'CONSTRAINT_REF') { xml.reference node.reference }
        when CPrimitiveObject
          xml.children('xsi:type' => 'C_PRIMITIVE_OBJECT') { emit_primitive_body(xml, node.item) }
        when OpenEHRProfile::DataTypes::Quantity::CDvOrdinal
          xml.children('xsi:type' => 'C_DV_ORDINAL') { emit_ordinal_body(xml, node) }
        when OpenEHRProfile::DataTypes::Text::CCodePhrase
          xml.children('xsi:type' => 'C_CODE_PHRASE') { emit_code_phrase_body(xml, node) }
        when CComplexObject
          xml.children('xsi:type' => 'C_COMPLEX_OBJECT') { emit_c_object_body(xml, node) }
        else
          raise ArgumentError, "XMLSerializer cannot emit a #{node.class} node"
        end
      end

      def emit_archetype_slot_body(xml, node)
        xml.rm_type_name node.rm_type_name
        xml.occurrence { emit_interval(xml, node.occurrences) }
        xml.node_id node.node_id if node.node_id
        emit_assertions(xml, 'includes', node.includes)
        emit_assertions(xml, 'excludes', node.excludes)
      end

      def emit_assertions(xml, tag, assertions)
        return if assertions.nil?

        xml.tag!(tag) { assertions.each { |a| xml.assertion a.string_expression } }
      end

      def emit_primitive_body(xml, item)
        xml.primitive_type item.type
        if item.is_a?(Primitive::CBoolean)
          xml.true_valid item.true_valid
          xml.false_valid item.false_valid
        elsif item.respond_to?(:pattern) && item.pattern
          xml.pattern item.pattern
        elsif item.list
          item.list.each { |v| xml.item literal(v) }
        elsif item.range
          xml.range { emit_bound_interval(xml, item.range) }
        end
        xml.assumed_value literal(item.assumed_value) if item.has_assumed_value?
      end

      def emit_bound_interval(xml, range)
        xml.lower literal(range.lower) unless range.lower_unbounded?
        xml.upper literal(range.upper) unless range.upper_unbounded?
      end

      def literal(value)
        value.respond_to?(:value) ? value.value.to_s : value.to_s
      end

      def emit_ordinal_body(xml, node)
        return if node.any_allowed?

        node.list.each do |o|
          xml.item do
            xml.value o.value
            xml.symbol o.symbol.code_string
          end
        end
        xml.assumed_value literal(node.assumed_value) if node.has_assumed_value?
      end

      def emit_code_phrase_body(xml, node)
        return if node.any_allowed?

        xml.terminology_id node.terminology_id.value
        node.code_list.each { |c| xml.code c }
      end

      def emit_term_bindings(xml, term_bindings)
        return if term_bindings.nil?

        term_bindings.each do |terminology, codes|
          codes.each do |code, bindings|
            code_phrase = Array(bindings).first
            xml.term_bindings do
              xml.terminology terminology
              xml.code code
              xml.value "#{code_phrase.terminology_id.value}::#{code_phrase.code_string}"
            end
          end
        end
      end
    end
  end
end
