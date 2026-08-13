# frozen_string_literal: true

require 'rexml/document'
require 'builder'
require_relative 'base'

module OpenEHR
  module Serializer
    # Emits the canonical openEHR ITS-XML AOM 1.4 shape for the parts
    # that have a verifiable ground truth: <occurrences> (plural),
    # xsi:type dispatch on <attributes>/<children>, nested
    # terminology_id/code_list, and real ASSERTION expression trees.
    # This gem's own OPTParser (lib/openehr/parser/opt_parser.rb) reads
    # exactly this shape for the <definition> constraint tree - verified
    # against real Ocean Template Designer-generated .opt fixtures in
    # spec/lib/openehr/opt_parser/ - so the two no longer contradict
    # each other. <ontology>'s attribute-style term_definitions follows
    # the same confirmed-from-.opt convention; term_bindings/
    # constraint_bindings and the header extras (uid/translations/etc.)
    # have no directly-comparable real fixture in this repo, so they
    # follow the same attribute-style spirit for internal consistency -
    # XMLArchetypeParser (lib/openehr/parser/xml_archetype_parser.rb) is
    # the authority for reading them back.
    class XMLSerializer < BaseSerializer
      def header
        header = +''
        xml = Builder::XmlMarkup.new(:indent => 2, :target => header)
        xml.archetype_id { xml.value @archetype.archetype_id.value }
        xml.uid { xml.value @archetype.uid.value } if @archetype.uid
        xml.adl_version @archetype.adl_version if @archetype.adl_version
        xml.parent_archetype_id { xml.value @archetype.parent_archetype_id.value } if @archetype.parent_archetype_id
        xml.concept @archetype.concept
        xml.original_language do
          xml.terminology_id { xml.value @archetype.original_language.terminology_id.value }
          xml.code_string @archetype.original_language.code_string
        end
        emit_translations(xml, @archetype.translations)
        return header
      end

      def description
        desc = +''
        xml = Builder::XmlMarkup.new(:indent => 2, :target => desc)
        ad = @archetype.description
        if ad
          xml.description do
            ad.original_author.each { |key, value| xml.original_author(value, 'id' => key) }
            (ad.other_contributors || []).each { |co| xml.other_contributors co }
            xml.lifecycle_state ad.lifecycle_state
            xml.details { ad.details.each { |lang, item| emit_description_detail(xml, lang, item) } }
          end
        end
        return desc
      end

      def definition
        definition = +''
        xml = Builder::XmlMarkup.new(:indent => 2, :target => definition)
        xml.definition { emit_c_object_body(xml, @archetype.definition) }
        return definition
      end

      def ontology
        ontology = +''
        ao = @archetype.ontology
        xml = Builder::XmlMarkup.new(:indent => 2, :target => ontology)
        xml.ontology do
          xml.primary_language ao.primary_language if ao.primary_language
          xml.specialisation_depth ao.specialisation_depth
          (ao.languages_available || []).each { |lang| xml.languages_available lang }
          (ao.terminologies_available || []).each { |t| xml.terminologies_available t }
          emit_term_definitions(xml, 'term_definitions', ao.term_definitions)
          emit_term_definitions(xml, 'constraint_definitions', ao.constraint_definitions) if ao.constraint_definitions
          emit_bindings(xml, 'term_bindings', ao.term_bindings) { |cp| "#{cp.terminology_id.value}::#{cp.code_string}" }
          emit_bindings(xml, 'constraint_bindings', ao.constraint_bindings) { |uri| uri.value }
        end
      end

      def merge
        archetype = "<?xml version='1.0' encoding='UTF-8'?>" + NL +
          "<archetype xmlns=\"http://schemas.openehr.org/v1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">" + NL +
          header + description + definition + emit_invariants + ontology + '</archetype>'
        return archetype
      end

      include OpenEHR::AM::Archetype::ConstraintModel
      Primitive = OpenEHR::AM::Archetype::ConstraintModel::Primitive
      AssertionModel = OpenEHR::AM::Archetype::Assertion
      OpenEHRProfile = OpenEHR::AM::OpenEHRProfile

      PRIMITIVE_XSI_TYPES = {
        Primitive::CBoolean => 'C_BOOLEAN',
        Primitive::CString => 'C_STRING',
        Primitive::CInteger => 'C_INTEGER',
        Primitive::CReal => 'C_REAL',
        Primitive::CDate => 'C_DATE',
        Primitive::CDateTime => 'C_DATE_TIME',
        Primitive::CTime => 'C_TIME',
        Primitive::CDuration => 'C_DURATION'
      }.freeze

      private

      def emit_translations(xml, translations)
        return if translations.nil? || translations.empty?

        xml.translations do
          translations.each { |code, details| emit_translation_item(xml, code, details) }
        end
      end

      def emit_translation_item(xml, code, details)
        xml.tag!('translation', 'language' => code) do
          xml.language do
            xml.terminology_id { xml.value details.language.terminology_id.value }
            xml.code_string details.language.code_string
          end
          (details.author || {}).each { |k, v| xml.author(v, 'id' => k) }
          xml.accreditation details.accreditation if details.accreditation
          (details.other_details || {}).each { |k, v| xml.other_details(v, 'id' => k) }
        end
      end

      def emit_description_detail(xml, lang, item)
        xml.language do
          xml.terminology_id { xml.value item.language.terminology_id.value }
          xml.code_string lang
        end
        xml.purpose item.purpose
        (item.keywords || []).each { |word| xml.keywords word }
        xml.use item.use if item.use
        xml.misuse item.misuse if item.misuse
        xml.copyright item.copyright if item.copyright
        (item.original_resource_uri || {}).each { |k, v| xml.original_resource_uri(v, 'id' => k) }
        (item.other_details || {}).each { |k, v| xml.other_details(v, 'id' => k) }
      end

      def emit_invariants
        invariants = @archetype.respond_to?(:invariants) ? @archetype.invariants : nil
        return '' if invariants.nil? || invariants.empty?

        text = +''
        xml = Builder::XmlMarkup.new(:indent => 2, :target => text)
        xml.invariants { invariants.each { |assertion| emit_assertion(xml, assertion) } }
        text
      end

      # Emits a C_OBJECT's own fields (rm_type_name/occurrences/node_id
      # plus, unless any_allowed?, its attributes) directly into the
      # current xml element - used both for the root <definition> and,
      # via emit_child, for every nested C_COMPLEX_OBJECT. Matches
      # OPTParser#c_archetype_root/#c_complex_object exactly.
      def emit_c_object_body(xml, node)
        xml.rm_type_name node.rm_type_name
        xml.occurrences { emit_interval(xml, node.occurrences) }
        xml.node_id node.node_id
        return if node.any_allowed?

        node.attributes.each { |a| emit_attribute(xml, a) }
      end

      def emit_interval(xml, interval)
        xml.lower_included interval.lower_included? unless interval.lower_included?.nil?
        xml.upper_included interval.upper_included? unless interval.upper_included?.nil?
        xml.lower_unbounded interval.lower_unbounded?
        xml.upper_unbounded interval.upper_unbounded?
        xml.lower interval.lower unless interval.lower_unbounded?
        xml.upper interval.upper unless interval.upper_unbounded?
      end

      # <attributes> itself carries the xsi:type discriminator
      # (C_SINGLE_ATTRIBUTE/C_MULTIPLE_ATTRIBUTE) - OPTParser#attributes
      # dispatches on exactly this attribute to pick c_single_attribute
      # vs c_multiple_attribute; without it, this gem's own OPTParser
      # cannot read its own XMLSerializer output back at all.
      def emit_attribute(xml, attribute)
        xsi_type = attribute.is_a?(CMultipleAttribute) ? 'C_MULTIPLE_ATTRIBUTE' : 'C_SINGLE_ATTRIBUTE'
        xml.attributes('xsi:type' => xsi_type) do
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
      # can be a mix of concrete constraint node types. Matches
      # OPTParser#children's dispatch exactly.
      def emit_child(xml, node)
        case node
        when ArchetypeSlot
          xml.children('xsi:type' => 'ARCHETYPE_SLOT') { emit_archetype_slot_body(xml, node) }
        when ArchetypeInternalRef
          xml.children('xsi:type' => 'ARCHETYPE_INTERNAL_REF') do
            xml.rm_type_name node.rm_type_name
            xml.occurrences { emit_interval(xml, node.occurrences) } if node.occurrences
            xml.target_path node.target_path
          end
        when ConstraintRef
          xml.children('xsi:type' => 'CONSTRAINT_REF') do
            xml.rm_type_name node.rm_type_name
            xml.occurrences { emit_interval(xml, node.occurrences) } if node.occurrences
            xml.reference node.reference
          end
        when CPrimitiveObject
          xml.children('xsi:type' => 'C_PRIMITIVE_OBJECT') { emit_primitive_object_body(xml, node) }
        when OpenEHRProfile::DataTypes::Quantity::CDvOrdinal
          xml.children('xsi:type' => 'C_DV_ORDINAL') { emit_ordinal_body(xml, node) }
        when OpenEHRProfile::DataTypes::Quantity::CDvScale
          xml.children('xsi:type' => 'C_DV_SCALE') { emit_scale_body(xml, node) }
        when OpenEHRProfile::DataTypes::Quantity::CDvQuantity
          xml.children('xsi:type' => 'C_DV_QUANTITY') { emit_dv_quantity_body(xml, node) }
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
        xml.occurrences { emit_interval(xml, node.occurrences) }
        xml.node_id node.node_id if node.node_id
        emit_assertions(xml, 'includes', node.includes)
        emit_assertions(xml, 'excludes', node.excludes)
      end

      def emit_assertions(xml, tag, assertions)
        return if assertions.nil?

        xml.tag!(tag) { assertions.each { |a| emit_assertion(xml, a) } }
      end

      # ASSERTION: tag (optional) + string_expression (optional,
      # round-trip convenience - OPTParser doesn't require it) + a real
      # expression tree, matching OPTParser#assertions/#expr_leaf/
      # #expr_binary_operator (rather than the previous flat
      # <assertion>text</assertion>, which Assertion#expression='s
      # non-nil invariant made impossible to read back at all).
      def emit_assertion(xml, assertion)
        xml.tag assertion.tag if assertion.tag
        xml.string_expression assertion.string_expression if assertion.string_expression
        emit_expression(xml, assertion.expression)
      end

      def emit_expression(xml, expression)
        case expression
        when AssertionModel::ExprBinaryOperator
          xml.expression('xsi:type' => 'EXPR_BINARY_OPERATOR') { emit_binary_operator_body(xml, expression) }
        when AssertionModel::ExprUnaryOperator
          xml.expression('xsi:type' => 'EXPR_UNARY_OPERATOR') { emit_unary_operator_body(xml, expression) }
        when AssertionModel::ExprLeaf
          xml.expression('xsi:type' => 'EXPR_LEAF') { emit_expr_leaf_body(xml, expression) }
        else
          raise ArgumentError, "XMLSerializer cannot emit a #{expression.class} expression"
        end
      end

      def emit_binary_operator_body(xml, expression)
        xml.type expression.type
        xml.operator operator_value(expression.operator)
        xml.precedence_overridden expression.precedence_overridden
        emit_operand(xml, 'left_operand', expression.left_operand)
        emit_operand(xml, 'right_operand', expression.right_operand)
      end

      def emit_unary_operator_body(xml, expression)
        xml.type expression.type
        xml.operator operator_value(expression.operator)
        xml.precedence_overridden expression.precedence_overridden
        emit_operand(xml, 'operand', expression.operand)
      end

      # ADLParser and OPTParser disagree on how they build
      # ExprOperator#operator: the ADL grammar assigns a bare
      # OperatorKind::OP_* Integer constant directly, while OPTParser's
      # reader wraps it in an OperatorKind object - accept either.
      def operator_value(operator)
        operator.respond_to?(:value) ? operator.value : operator
      end

      # left_operand/right_operand/operand elements carry the same
      # xsi:type-tagged shape as a top-level <expression> - reuse the
      # same dispatch/body emission, just under a different tag name.
      def emit_operand(xml, tag, operand)
        case operand
        when AssertionModel::ExprBinaryOperator
          xml.tag!(tag, 'xsi:type' => 'EXPR_BINARY_OPERATOR') { emit_binary_operator_body(xml, operand) }
        when AssertionModel::ExprUnaryOperator
          xml.tag!(tag, 'xsi:type' => 'EXPR_UNARY_OPERATOR') { emit_unary_operator_body(xml, operand) }
        when AssertionModel::ExprLeaf
          xml.tag!(tag, 'xsi:type' => 'EXPR_LEAF') { emit_expr_leaf_body(xml, operand) }
        else
          raise ArgumentError, "XMLSerializer cannot emit a #{operand.class} expression"
        end
      end

      # OPTParser#expr_leaf dispatches on <type> (not the <item>'s own
      # xsi:type) via `send type.downcase, item_leaf`: a bare "String"
      # reference (a path, e.g. "archetype_id/value") reads back via
      # its #string method (plain text); any C_* type reads back via
      # the matching c_* primitive-item reader.
      def emit_expr_leaf_body(xml, leaf)
        xml.type leaf.type
        if leaf.item.is_a?(Primitive::CPrimitive)
          emit_primitive_item(xml, leaf.item)
        else
          xml.item(leaf.item.to_s, 'xsi:type' => 'xsd:string')
        end
        xml.reference_type leaf.reference_type
      end

      def emit_primitive_object_body(xml, node)
        xml.rm_type_name node.rm_type_name
        xml.occurrences { emit_interval(xml, node.occurrences) }
        xml.node_id node.node_id if node.node_id
        emit_primitive_item(xml, node.item)
      end

      def emit_primitive_item(xml, item)
        xml.item('xsi:type' => primitive_xsi_type(item)) { emit_primitive_item_body(xml, item) }
      end

      def primitive_xsi_type(item)
        PRIMITIVE_XSI_TYPES.fetch(item.class) { raise ArgumentError, "XMLSerializer cannot emit a #{item.class} primitive" }
      end

      def emit_primitive_item_body(xml, item)
        if item.is_a?(Primitive::CBoolean)
          emit_boolean_item_body(xml, item)
        elsif item.is_a?(Primitive::CDuration)
          emit_duration_item_body(xml, item)
        elsif item.respond_to?(:pattern) && item.pattern
          xml.pattern item.pattern
          emit_assumed_value(xml, item)
        elsif item.list
          item.list.each { |v| xml.list literal(v) }
          emit_assumed_value(xml, item)
        elsif item.range
          xml.range { emit_interval(xml, item.range) }
          emit_assumed_value(xml, item)
        else
          emit_assumed_value(xml, item)
        end
      end

      def emit_boolean_item_body(xml, item)
        xml.true_valid item.true_valid unless item.true_valid.nil?
        xml.false_valid item.false_valid unless item.false_valid.nil?
        xml.assumed_value item.assumed_value unless item.assumed_value.nil?
      end

      # C_DURATION's range bounds are ISO8601 duration strings (DV_
      # DURATION), not plain numbers, so it can't reuse emit_interval;
      # matches OPTParser#duration_range/#duration_bound exactly.
      def emit_duration_item_body(xml, item)
        if item.pattern
          xml.pattern item.pattern
        elsif item.list
          item.list.each { |v| xml.list v }
        elsif item.range
          xml.range { emit_duration_range(xml, item.range) }
        end
        emit_assumed_value(xml, item)
      end

      def emit_duration_range(xml, range)
        unless range.lower_unbounded?
          xml.lower range.lower.value
          xml.lower_included range.lower_included?
        end
        xml.lower_unbounded range.lower_unbounded?
        unless range.upper_unbounded?
          xml.upper range.upper.value
          xml.upper_included range.upper_included?
        end
        xml.upper_unbounded range.upper_unbounded?
      end

      def emit_assumed_value(xml, item)
        xml.assumed_value literal(item.assumed_value) if item.has_assumed_value?
      end

      def literal(value)
        value.respond_to?(:value) ? value.value.to_s : value.to_s
      end

      # DV_ORDINAL.symbol is spec'd as DV_CODED_TEXT (code lives at
      # symbol.defining_code, not symbol itself) - matches
      # OPTParser#dv_ordinal_item's nested symbol/defining_code shape.
      def emit_ordinal_body(xml, node)
        xml.rm_type_name node.rm_type_name
        xml.occurrences { emit_interval(xml, node.occurrences) }
        xml.node_id node.node_id if node.node_id
        return if node.any_allowed?

        node.list.each { |o| emit_ordinal_item(xml, o) }
        emit_assumed_value(xml, node)
      end

      def emit_ordinal_item(xml, item)
        xml.list do
          xml.value item.value
          xml.symbol { xml.defining_code { emit_code_phrase_fields(xml, item.symbol.defining_code) } }
        end
      end

      # RM 1.1.0: same shape as C_DV_ORDINAL, but DV_SCALE.value is Real.
      def emit_scale_body(xml, node)
        xml.rm_type_name node.rm_type_name
        xml.occurrences { emit_interval(xml, node.occurrences) }
        xml.node_id node.node_id if node.node_id
        return if node.any_allowed?

        node.list.each { |o| emit_ordinal_item(xml, o) }
      end

      def emit_dv_quantity_body(xml, node)
        xml.rm_type_name node.rm_type_name
        xml.occurrences { emit_interval(xml, node.occurrences) }
        xml.node_id node.node_id if node.node_id
        return if node.any_allowed?

        xml.property { emit_code_phrase_fields(xml, node.property) } if node.property
        (node.list || []).each { |item| emit_quantity_item(xml, item) }
        emit_dv_quantity_assumed_value(xml, node.assumed_value) if node.assumed_value
      end

      def emit_quantity_item(xml, item)
        xml.list do
          xml.units item.units
          xml.magnitude { emit_interval(xml, item.magnitude) } if item.magnitude
          xml.precision { emit_interval(xml, item.precision) } unless item.precision_unconstrained?
        end
      end

      # assumed_value here is a real DV_QUANTITY (plain magnitude/
      # precision, not a range) - distinct from CQuantityItem's ranged
      # list items above.
      def emit_dv_quantity_assumed_value(xml, assumed_value)
        xml.assumed_value do
          xml.units assumed_value.units
          xml.magnitude assumed_value.magnitude
          xml.precision assumed_value.precision unless assumed_value.precision.nil?
        end
      end

      def emit_code_phrase_body(xml, node)
        xml.rm_type_name node.rm_type_name
        xml.occurrences { emit_interval(xml, node.occurrences) }
        xml.node_id node.node_id if node.node_id
        return if node.any_allowed?

        xml.terminology_id { xml.value node.terminology_id.value }
        node.code_list.each { |c| xml.code_list c }
      end

      def emit_code_phrase_fields(xml, code_phrase)
        xml.terminology_id { xml.value code_phrase.terminology_id.value }
        xml.code_string code_phrase.code_string
      end

      def emit_term_definitions(xml, keyword, term_definitions)
        term_definitions.each do |lang, terms|
          terms.each do |code, term|
            xml.tag!(keyword, 'language' => lang, 'code' => code) do
              term.items.each { |key, value| xml.items(value, 'id' => key) }
            end
          end
        end
      end

      def emit_bindings(xml, keyword, bindings)
        return if bindings.nil?

        bindings.each do |terminology, codes|
          codes.each do |code, binding|
            value_object = Array(binding).first
            xml.tag!(keyword, yield(value_object), 'terminology' => terminology, 'code' => code)
          end
        end
      end
    end
  end
end
