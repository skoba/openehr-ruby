# frozen_string_literal: true

require_relative 'base'

module OpenEHR
  module Serializer
    class ADLSerializer < BaseSerializer
      def header
        hd = +'archetype'
        unless @archetype.adl_version.nil?
          hd << " (adl_version = #{@archetype.adl_version})"
        end
        hd << (NL+INDENT + "#{@archetype.archetype_id.value}"+(NL*2))
        hd << ('concept'+NL+ INDENT+"[#{@archetype.concept}]"+NL)
        hd << (NL+'language'+NL+INDENT+'original_language = <['+
          @archetype.original_language.terminology_id.value+'::'+
          @archetype.original_language.code_string+']>'+NL)
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
            desc << ((INDENT*2)+'["'+lang+'"] = <'+NL)
            desc << ((INDENT*3)+'language = <['+
              item.language.terminology_id.value+'::'+
              item.language.code_string+']>'+NL)
            desc << ((INDENT*3)+'purpose = <"'+item.purpose+'">'+NL)
            if item.keywords then
              desc << ((INDENT*3)+'keywords = <')
              item.keywords.each do |word|
                desc << ('"'+word+'",')
              end
              desc.chop! << ('>'+NL)
            end
            desc << ((INDENT*3)+'use = <"'+item.use+'">'+NL) if item.use
            desc << ((INDENT*3)+'misuse = <"'+item.misuse+'">'+NL) if item.misuse
            desc << ((INDENT*3)+'copyright = <"'+item.copyright+'">'+NL) if item.copyright
            if item.original_resource_uri
              desc << ((INDENT*3) + 'original_resource_uri = <')
              item.original_resource_uri.each do |k,v|
                desc << ((INDENT*4)+'["'+k+'"] = <"'+v+'">'+NL)
              end
              desc << ((INDENT*3)+'>'+NL)
            end
            if item.other_details
              desc << ((INDENT*3) + 'other_details = <')
              item.other_details.each do |k,v|
                desc << ((INDENT*4)+'["'+k+'"] = <"'+v+'">'+NL)
              end
              desc << ((INDENT*3)+'>'+NL)
            end
            desc << ((INDENT*2)+'>'+NL)
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
        ontology << string_list_line('languages_available', ao.languages_available)
        ontology << string_list_line('terminologies_available', ao.terminologies_available)
        ontology << (INDENT + 'term_definitions = <' + NL)
        ao.term_definitions.each do |lang, items|
          ontology << ((INDENT*2) + "[\"#{lang}\"] = <" + NL)
          ontology << ((INDENT*3) + 'items = <'  + NL)
          items.each do |code, item|
            ontology << ((INDENT*4) + "[\"#{code}\"] = <" + NL)
            item.items.each do |name, desc|
              ontology << ((INDENT*5) + "#{name} = <\"#{desc}\">" + NL)
            end
            ontology << ((INDENT*4) + '>'+NL)
          end
          ontology << ((INDENT*3) + '>' + NL)
          ontology << ((INDENT*2) + '>' + NL)
        end
        ontology << (INDENT + '>' + NL)
        ontology << term_bindings_block(ao.term_bindings)
        ontology
      end

      def merge
        return header + NL + description + NL + definition + NL + ontology
      end

      include OpenEHR::AM::Archetype::ConstraintModel
      Primitive = OpenEHR::AM::Archetype::ConstraintModel::Primitive
      OpenEHRProfile = OpenEHR::AM::OpenEHRProfile

      private

      def string_list_line(keyword, values)
        return '' if values.nil? || values.empty?

        INDENT + "#{keyword} = <" + values.map { |v| "\"#{v}\"" }.join(', ') + '>' + NL
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

      # Recursive cADL emitter for a single C_OBJECT node, dispatching
      # on its concrete class. Unsupported domain types (e.g.
      # C_DV_QUANTITY's dADL block syntax, C_DV_STATE) deliberately
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
          head + " matches {#{inline_body(children.first)}}" + NL
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
          node.is_a?(OpenEHRProfile::DataTypes::Text::CCodePhrase)
      end

      def inline_body(node)
        case node
        when CPrimitiveObject
          primitive_body(node.item)
        when ConstraintRef
          "[#{node.reference}]"
        when OpenEHRProfile::DataTypes::Quantity::CDvOrdinal
          ordinal_body(node)
        when OpenEHRProfile::DataTypes::Text::CCodePhrase
          code_phrase_body(node)
        end
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

        body = node.list.map { |o| "#{o.value}|[#{o.symbol.code_string}]" }.join(', ')
        with_assumed_value(body, node)
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
