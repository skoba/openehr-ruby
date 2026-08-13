# frozen_string_literal: true

require_relative 'base'

module OpenEHR
  module Serializer
    class ADLSerializer < BaseSerializer
      def header
        hd = +'archetype'
        hd << archetype_meta_data_clause
        hd << (NL+INDENT + "#{@archetype.archetype_id.value}"+NL)
        hd << specialise_section
        hd << (NL+'concept'+NL+ INDENT+"[#{@archetype.concept}]"+NL)
        hd << (NL+'language'+NL+INDENT+'original_language = <['+
          @archetype.original_language.terminology_id.value+'::'+
          @archetype.original_language.code_string+']>'+NL)
        hd << translations_block(@archetype.translations)
        return hd
      end

      def description
        desc = +''
        if @archetype.description
          ad = @archetype.description
          desc << ('description' + NL)
          desc << (INDENT + 'original_author = <' + NL)
          ad.original_author.each do |k,v|
            desc << (INDENT+INDENT+'["'+k+'"] = <"'+v+'">'+NL)
          end
          desc << (INDENT+'>'+NL)
          desc << (INDENT+'lifecycle_state = <"'+ad.lifecycle_state+'">'+NL)
          desc << (INDENT+'details = <'+NL)
          ad.details.each do |lang,item|
            desc << description_details_item(lang, item)
          end
          desc << (INDENT+'>'+NL)
        end
        return desc
      end

      def definition
        'definition' + NL + emit_c_object(@archetype.definition, 1)
      end

      def ontology
        ao = @archetype.ontology
        ontology = 'ontology'+NL
        ontology << primary_language_line(ao.primary_language)
        ontology << string_list_line('languages_available', ao.languages_available)
        ontology << string_list_line('terminologies_available', ao.terminologies_available)
        ontology << term_definitions_block(ao.term_definitions)
        ontology << term_definitions_block(ao.constraint_definitions, 'constraint_definitions') if ao.constraint_definitions
        ontology << term_bindings_block(ao.term_bindings)
        ontology << constraint_bindings_block(ao.constraint_bindings)
        ontology
      end

      def merge
        return header + NL + description + NL + definition + NL + invariant_section + ontology
      end

      include OpenEHR::AM::Archetype::ConstraintModel
      Primitive = OpenEHR::AM::Archetype::ConstraintModel::Primitive
      OpenEHRProfile = OpenEHR::AM::OpenEHRProfile

      private

      def string_list_line(keyword, values)
        return '' if values.nil? || values.empty?

        INDENT + "#{keyword} = <" + values.map { |v| "\"#{v}\"" }.join(', ') + '>' + NL
      end

      # archetype (adl_version = ...; uid = ...) - a ';'-separated
      # metadata clause. Empty when neither is present, so callers that
      # never set uid see byte-identical output to before uid support.
      def archetype_meta_data_clause
        items = []
        items << "adl_version = #{@archetype.adl_version}" if @archetype.adl_version
        items << "uid = #{@archetype.uid.value}" if @archetype.uid
        return '' if items.empty?

        " (#{items.join('; ')})"
      end

      def specialise_section
        return '' if @archetype.parent_archetype_id.nil?

        'specialise' + NL + INDENT + @archetype.parent_archetype_id.value + NL
      end

      def translations_block(translations)
        return '' if translations.nil? || translations.empty?

        block = INDENT + 'translations = <' + NL
        translations.each { |code, details| block << translation_item_block(code, details) }
        block << (INDENT + '>' + NL)
      end

      def translation_item_block(code, details)
        block = (INDENT*2) + "[\"#{code}\"] = <" + NL
        block << ((INDENT*3) + "language = <[#{details.language.terminology_id.value}::#{details.language.code_string}]>" + NL)
        block << keyed_map_block('author', details.author) if details.author
        block << ((INDENT*3) + "accreditation = <\"#{details.accreditation}\">" + NL) if details.accreditation
        block << keyed_map_block('other_details', details.other_details) if details.other_details
        block << ((INDENT*2) + '>' + NL)
      end

      def invariant_section
        invariants = @archetype.invariants
        return '' if invariants.nil? || invariants.empty?

        block = 'invariant' + NL
        invariants.each { |assertion| block << (INDENT + assertion.string_expression + NL) }
        block << NL
      end

      def primary_language_line(primary_language)
        return '' if primary_language.nil?

        INDENT + "primary_language = <\"#{primary_language}\">" + NL
      end

      def description_details_item(lang, item)
        block = (INDENT*2)+'["'+lang+'"] = <'+NL
        block << description_language_line(item.language)
        block << ((INDENT*3)+'purpose = <"'+item.purpose+'">'+NL)
        block << description_keywords_line(item) if item.keywords
        block << optional_field_line('use', item.use)
        block << optional_field_line('misuse', item.misuse)
        block << optional_field_line('copyright', item.copyright)
        block << keyed_map_block('original_resource_uri', item.original_resource_uri) if item.original_resource_uri
        block << keyed_map_block('other_details', item.other_details) if item.other_details
        block << ((INDENT*2)+'>'+NL)
      end

      def description_language_line(language)
        (INDENT*3)+'language = <['+
          language.terminology_id.value+'::'+
          language.code_string+']>'+NL
      end

      def optional_field_line(keyword, value)
        return '' if value.nil?

        (INDENT*3)+"#{keyword} = <\"#{value}\">"+NL
      end

      def description_keywords_line(item)
        block = (INDENT*3)+'keywords = <'
        item.keywords.each do |word|
          block << ('"'+word+'",')
        end
        block.chop! << ('>'+NL)
      end

      def keyed_map_block(keyword, hash)
        block = (INDENT*3) + "#{keyword} = <"
        hash.each do |k,v|
          block << ((INDENT*4)+'["'+k+'"] = <"'+v+'">'+NL)
        end
        block << ((INDENT*3)+'>'+NL)
      end

      def term_definitions_block(term_definitions, keyword = 'term_definitions')
        block = INDENT + "#{keyword} = <" + NL
        term_definitions.each do |lang, items|
          block << ((INDENT*2) + "[\"#{lang}\"] = <" + NL)
          block << ((INDENT*3) + 'items = <'  + NL)
          items.each do |code, item|
            block << ((INDENT*4) + "[\"#{code}\"] = <" + NL)
            item.items.each do |name, desc|
              block << ((INDENT*5) + "#{name} = <\"#{desc}\">" + NL)
            end
            block << ((INDENT*4) + '>'+NL)
          end
          block << ((INDENT*3) + '>' + NL)
          block << ((INDENT*2) + '>' + NL)
        end
        block << (INDENT + '>' + NL)
      end

      def term_bindings_block(term_bindings)
        return '' if term_bindings.nil? || term_bindings.empty?

        block = INDENT + 'term_bindings = <' + NL
        term_bindings.each do |terminology, codes|
          block << ((INDENT*2) + "[\"#{terminology}\"] = <" + NL)
          block << ((INDENT*3) + 'items = <' + NL)
          codes.each do |code, bindings|
            code_phrase = Array(bindings).first
            block << ((INDENT*4) + "[\"#{code}\"] = <[#{code_phrase.terminology_id.value}::#{code_phrase.code_string}]>" + NL)
          end
          block << ((INDENT*3) + '>' + NL)
          block << ((INDENT*2) + '>' + NL)
        end
        block << (INDENT + '>' + NL)
      end

      # constraint_bindings mirrors term_bindings' 3-level nesting
      # (terminology -> items -> code), but each value is a bare/unquoted
      # URI (a DvUri) rather than a qualified term code reference.
      def constraint_bindings_block(constraint_bindings)
        return '' if constraint_bindings.nil? || constraint_bindings.empty?

        block = INDENT + 'constraint_bindings = <' + NL
        constraint_bindings.each do |terminology, codes|
          block << ((INDENT*2) + "[\"#{terminology}\"] = <" + NL)
          block << ((INDENT*3) + 'items = <' + NL)
          codes.each do |code, uri|
            block << ((INDENT*4) + "[\"#{code}\"] = <#{uri.value}>" + NL)
          end
          block << ((INDENT*3) + '>' + NL)
          block << ((INDENT*2) + '>' + NL)
        end
        block << (INDENT + '>' + NL)
      end

      # Recursive cADL emitter for a single C_OBJECT node, dispatching
      # on its concrete class. Domain types with no ADL 1.4 grammar rule
      # (C_DV_SCALE, C_DV_STATE - both RM 1.1.0+ additions) deliberately
      # raise rather than emit a guess at their syntax.
      def emit_c_object(node, depth)
        case node
        when ArchetypeSlot
          emit_archetype_slot(node, depth)
        when ArchetypeInternalRef
          emit_internal_ref(node, depth)
        when ConstraintRef
          emit_constraint_ref(node, depth)
        when CComplexObject
          emit_complex_object(node, depth)
        when OpenEHRProfile::DataTypes::Quantity::CDvScale
          raise ArgumentError,
                'ADLSerializer cannot emit C_DV_SCALE in cADL - the ADL 1.4 grammar has no C_DV_SCALE rule ' \
                '(RM 1.1.0 addition); use the XML serializer instead'
        when OpenEHRProfile::DataTypes::Basic::CDvState
          raise ArgumentError,
                'ADLSerializer cannot emit C_DV_STATE in cADL - the ADL 1.4 grammar has no C_DV_STATE rule; ' \
                'use the XML serializer instead'
        else
          raise ArgumentError, "ADLSerializer cannot emit a #{node.class} node"
        end
      end

      def emit_complex_object(node, depth)
        head = complex_object_head(node, depth)
        if node.any_allowed?
          head + ' matches {*}' + NL
        else
          body = node.attributes.map { |a| emit_c_attribute(a, depth + 1) }.join
          head + ' matches {' + NL + body + (INDENT*depth) + '}' + NL
        end
      end

      def complex_object_head(node, depth)
        head = (INDENT*depth) + node.rm_type_name
        head += "[#{node.node_id}]" if node.node_id
        head += " occurrences matches {#{interval_literal(node.occurrences)}}" if show_interval?(node.occurrences)
        head
      end

      # A single attribute whose sole child is an inline-only node
      # (C_PRIMITIVE_OBJECT, CONSTRAINT_REF, C_CODE_PHRASE,
      # C_DV_ORDINAL) is flattened - its "matches {...}" IS the
      # attribute's own matches clause, with no nested TYPE wrapper,
      # matching real ADL 1.4 usage (e.g. "value matches {True}", not
      # "value matches { BOOLEAN matches {True} }"). Anything else
      # (C_COMPLEX_OBJECT, ARCHETYPE_SLOT, ARCHETYPE_INTERNAL_REF, or
      # more than one alternative) renders as nested block(s).
      def emit_c_attribute(attribute, depth)
        head = attribute_head(attribute, depth)
        children = attribute.children || []
        if children.size == 1 && inline?(children.first)
          head + " matches {#{inline_body(children.first, depth)}}" + NL
        else
          body = children.map { |c| emit_c_object(c, depth + 1) }.join
          head + ' matches {' + NL + body + (INDENT*depth) + '}' + NL
        end
      end

      def attribute_head(attribute, depth)
        head = (INDENT*depth) + attribute.rm_attribute_name
        head += " existence matches {#{interval_literal(attribute.existence)}}" if show_interval?(attribute.existence)
        head += " cardinality matches {#{cardinality_literal(attribute.cardinality)}}" if attribute.is_a?(CMultipleAttribute)
        head
      end

      def inline?(node)
        node.is_a?(CPrimitiveObject) || node.is_a?(ConstraintRef) ||
          node.is_a?(OpenEHRProfile::DataTypes::Quantity::CDvOrdinal) ||
          node.is_a?(OpenEHRProfile::DataTypes::Text::CCodePhrase) ||
          node.is_a?(OpenEHRProfile::DataTypes::Quantity::CDvQuantity)
      end

      def inline_body(node, depth)
        case node
        when CPrimitiveObject
          primitive_body(node.item)
        when ConstraintRef
          "[#{node.reference}]"
        when OpenEHRProfile::DataTypes::Quantity::CDvOrdinal
          ordinal_body(node)
        when OpenEHRProfile::DataTypes::Text::CCodePhrase
          code_phrase_body(node)
        when OpenEHRProfile::DataTypes::Quantity::CDvQuantity
          cdv_quantity_body(node, depth)
        end
      end

      # cADL syntax for C_DV_QUANTITY is a dADL-style block, not a short
      # inline literal like the other inline? types above - see the
      # adl_grammar.tt c_dv_quantity rule and CDvQuantityItems#value
      # (adl_helper.rb) for the exact shape this mirrors: property is a
      # qualified term code reference, list is an array of CQuantityItem
      # keyed by 1-based position (the key itself isn't stored on
      # CQuantityItem, so round-tripping only needs *a* stable key, not
      # the original one), and assumed_value is a real DV_QUANTITY (plain
      # magnitude/precision, not a range).
      def cdv_quantity_body(node, depth)
        return 'C_DV_QUANTITY < >' if node.any_allowed?

        body = 'C_DV_QUANTITY <' + NL
        body << quantity_property_line(node.property, depth + 1) if node.property
        body << quantity_list_block(node.list, depth + 1) if node.list
        body << assumed_quantity_block(node.assumed_value, depth + 1) if node.assumed_value
        body << ((INDENT*depth) + '>')
      end

      def quantity_property_line(property, depth)
        (INDENT*depth) + "property = <[#{property.terminology_id.value}::#{property.code_string}]>" + NL
      end

      def quantity_list_block(list, depth)
        block = (INDENT*depth) + 'list = <' + NL
        list.each_with_index { |item, index| block << quantity_item_block(item, index + 1, depth + 1) }
        block << ((INDENT*depth) + '>' + NL)
      end

      def quantity_item_block(item, key, depth)
        block = (INDENT*depth) + "[\"#{key}\"] = <" + NL
        block << ((INDENT*(depth+1)) + "units = <\"#{item.units}\">" + NL)
        block << ((INDENT*(depth+1)) + "magnitude = <|#{range_literal(item.magnitude)}|>" + NL) if item.magnitude
        block << ((INDENT*(depth+1)) + "precision = <|#{range_literal(item.precision)}|>" + NL) if item.precision
        block << ((INDENT*depth) + '>' + NL)
      end

      def assumed_quantity_block(assumed_value, depth)
        block = (INDENT*depth) + 'assumed_value = <' + NL
        block << ((INDENT*(depth+1)) + "units = <\"#{assumed_value.units}\">" + NL)
        block << ((INDENT*(depth+1)) + "magnitude = <#{assumed_value.magnitude}>" + NL)
        block << ((INDENT*(depth+1)) + "precision = <#{assumed_value.precision}>" + NL) unless assumed_value.precision.nil?
        block << ((INDENT*depth) + '>' + NL)
      end

      def emit_archetype_slot(node, depth)
        head = (INDENT*depth) + 'allow_archetype ' + node.rm_type_name
        head += "[#{node.node_id}]" if node.node_id
        head += " occurrences matches {#{interval_literal(node.occurrences)}}" if show_interval?(node.occurrences)
        lines = [head + ' matches {' + NL]
        lines << assertion_block(node.includes, 'include', depth + 1)
        lines << assertion_block(node.excludes, 'exclude', depth + 1)
        lines << ((INDENT*depth) + '}' + NL)
        lines.join
      end

      def assertion_block(assertions, keyword, depth)
        return '' if assertions.nil?

        lines = [(INDENT*depth) + keyword + NL]
        assertions.each { |a| lines << ((INDENT*(depth+1)) + a.string_expression + NL) }
        lines.join
      end

      def emit_internal_ref(node, depth)
        (INDENT*depth) + "use_node #{node.rm_type_name} #{node.target_path}" + NL
      end

      def emit_constraint_ref(node, depth)
        (INDENT*depth) + "[#{node.reference}]" + NL
      end

      def primitive_body(item)
        return boolean_body(item) if item.is_a?(Primitive::CBoolean)

        bounded_primitive_body(item)
      end

      def boolean_body(item)
        values = []
        values << 'True' if item.true_valid
        values << 'False' if item.false_valid
        with_assumed_value(values.join(', '), item)
      end

      def bounded_primitive_body(item)
        body =
          if item.respond_to?(:pattern) && item.pattern
            item.pattern.to_s
          elsif item.list
            item.list.map { |v| primitive_literal(v) }.join(', ')
          elsif item.range
            "|#{range_literal(item.range)}|"
          else
            return '*'
          end
        with_assumed_value(body, item)
      end

      def with_assumed_value(body, item)
        return body unless item.has_assumed_value?

        "#{body}; #{primitive_literal(item.assumed_value)}"
      end

      def primitive_literal(value)
        case value
        when String then "\"#{value}\""
        when true then 'True'
        when false then 'False'
        when Numeric then value.to_s
        else
          value.respond_to?(:value) ? value.value.to_s : value.to_s
        end
      end

      def bound_literal(bound)
        return nil if bound.nil?

        bound.respond_to?(:value) ? bound.value.to_s : bound.to_s
      end

      def range_literal(range)
        lo = bound_literal(range.lower)
        up = bound_literal(range.upper)
        if lo && up
          lo == up ? lo : "#{lo}..#{up}"
        elsif lo
          "#{range.lower_included? ? '>=' : '>'}#{lo}"
        elsif up
          "#{range.upper_included? ? '<=' : '<'}#{up}"
        else
          '*'
        end
      end

      def ordinal_body(node)
        return 'C_DV_ORDINAL < >' if node.any_allowed?

        body = node.list.map { |o| "#{o.value}|[#{ordinal_symbol_reference(o.symbol)}]" }.join(', ')
        with_assumed_value(body, node)
      end

      # The c_ordinal grammar rule builds symbol as a DV_CODED_TEXT
      # (code lives at symbol.defining_code, not symbol itself) - a bare
      # CODE_PHRASE-like symbol is also accepted, matching the dual
      # shape CDvOrdinal#valid_value? already tolerates.
      def ordinal_symbol_reference(symbol)
        code_phrase = symbol.respond_to?(:defining_code) ? symbol.defining_code : symbol
        "#{code_phrase.terminology_id.value}::#{code_phrase.code_string}"
      end

      def code_phrase_body(node)
        return '*' if node.any_allowed?

        "[#{node.terminology_id.value}::#{node.code_list.join(', ')}]"
      end

      def show_interval?(interval)
        return false if interval.nil?

        !(interval.lower == 1 && interval.upper == 1)
      end

      def interval_literal(interval)
        lo = interval.lower_unbounded? ? '0' : interval.lower.to_s
        up = interval.upper_unbounded? ? '*' : interval.upper.to_s
        "#{lo}..#{up}"
      end

      def cardinality_literal(cardinality)
        return '0..*; unordered' if cardinality.nil?

        flags = [cardinality.is_ordered? ? 'ordered' : 'unordered']
        flags << 'unique' if cardinality.is_unique?
        "#{interval_literal(cardinality.interval)}; #{flags.join('; ')}"
      end
    end
  end
end
