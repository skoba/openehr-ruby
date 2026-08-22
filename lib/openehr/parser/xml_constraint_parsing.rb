module OpenEHR
  module Parser
    # Structural/constraint-tree node builders (C_COMPLEX_OBJECT,
    # C_ATTRIBUTE, C_PRIMITIVE_OBJECT, ARCHETYPE_SLOT, ARCHETYPE_INTERNAL_REF,
    # CONSTRAINT_REF, ASSERTION) shared between OPTParser and
    # XMLArchetypeParser - both read the same canonical shape (see
    # lib/openehr/serializer/xml_serializer.rb's header comment for how
    # that shape was established as ground truth against real .opt
    # fixtures). Extracted from opt_parser.rb without behavior changes,
    # except: expr_unary_operator support and tag reading in assertions()
    # were both added here since XMLSerializer already emits them, and
    # occurrences()/numeric bounds are now real-aware where the caller
    # asks for it (C_REAL ranges were silently truncated to Integer via
    # String#to_i before this).
    module XMLConstraintParsing
      private

      def c_archetype_root(xml, node = Node.new)
        rm_type_name = text_on_path(xml, './rm_type_name')
        id = text_on_path(xml, './node_id')
        node.id = id unless id.nil? or id.empty?
        occurrences = occurrences(xml.xpath('./occurrences'))
        archetype_id = OpenEHR::RM::Support::Identification::ArchetypeID.new(value: text_on_path(xml, './archetype_id/value'))
        if node.root? or node.id.nil?
          node.path = "/"
        end
        component_terminologies(archetype_id, xml)
        OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot.new(rm_type_name: rm_type_name, node_id: node.id, path: node.path, occurrences: occurrences, archetype_id: archetype_id, attributes: attributes(xml.xpath('./attributes'), node))
      end

      def c_complex_object(xml, node)
        rm_type_name = xml.xpath('./rm_type_name').text
        node_id = xml.xpath('./node_id').text
        unless node_id.nil? or node_id.empty?
          node.id = node_id
          node.path = "#{node.path}[#{node.id}]"
        end
        OpenEHR::AM::Archetype::ConstraintModel::CComplexObject.new(rm_type_name: rm_type_name, node_id: node.id, path: node.path, occurrences: occurrences(xml.xpath('./occurrences')), attributes: attributes(xml.xpath('./attributes'), node))
      end

      def attributes(attributes_xml, node)
        attributes_xml.map do |attr|
          rm_attribute_name = attr.at('rm_attribute_name').text
          if node.root?
            path = "/#{rm_attribute_name}"
          else
            path = "#{node.path}/#{rm_attribute_name}"
          end
          child_node = Node.new(node)
          child_node.path = path
          child_node.id = node.id
          send attr.attributes['type'].text.downcase, attr, child_node
        end
      end

      # Each sibling child gets its own Node, copied fresh from the
      # attribute's node - c_complex_object mutates node.path/node.id
      # in place when a node_id is present, so sharing one Node across
      # a map() here would leak sibling A's path into sibling B (e.g. a
      # C_MULTIPLE_ATTRIBUTE with 2+ C_COMPLEX_OBJECT children, each
      # with its own node_id, would produce "/items[a][b]" instead of
      # "/items[a]" and "/items[b]").
      def children(children_xml, node)
        children_xml.map do |child|
          child_node = Node.new(node)
          child_node.path = node.path
          child_node.id = node.id
          type_name = child.attributes['type'].text
          handler = type_name.downcase
          if respond_to?(handler, true)
            send handler, child, child_node
          else
            # children is open to vendor/newer-model constraint extensions;
            # the other xsi:type dispatch sites are schema-closed. Preserve
            # the C_OBJECT core here, while warning that type-specific
            # constraints are dropped and validation becomes more permissive.
            warn "openehr parser: unknown constraint type \"#{type_name}\" at #{child_node.path}; treating as C_COMPLEX_OBJECT (type-specific constraints dropped)"
            c_complex_object(child, child_node)
          end
        end
      end

      def c_single_attribute(attr_xml, node)
        rm_attribute_name = attr_xml.at('rm_attribute_name').text
        existence = occurrences(attr_xml.at('existence'))
        OpenEHR::AM::Archetype::ConstraintModel::CSingleAttribute.new(rm_attribute_name: rm_attribute_name, existence: existence, path: node.path, children: children(attr_xml.xpath('./children'), node))
      end

      def c_multiple_attribute(attr_xml, node)
        rm_attribute_name = attr_xml.at('rm_attribute_name').text
        existence = occurrences(attr_xml.at('existence'))
        OpenEHR::AM::Archetype::ConstraintModel::CMultipleAttribute.new(rm_attribute_name: rm_attribute_name, existence: existence, path: node.path, cardinality: cardinality(attr_xml), children: children(attr_xml.xpath('./children'), node))
      end

      def archetype_slot(attr_xml, node)
        node_id = attr_xml.at('node_id').text
        node.id = node_id
        # Matches c_complex_object's path convention: a slot's own
        # node_id belongs in its path (e.g. "/items[at0053]"), not just
        # its parent attribute's path - without this, two slots under
        # the same C_MULTIPLE_ATTRIBUTE would collapse to one path.
        node.path = "#{node.path}[#{node.id}]" unless node_id.nil? || node_id.empty?
        rm_type_name = attr_xml.at('rm_type_name').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        includes_leaf = attr_xml.at('includes')
        includes = assertions(includes_leaf.children, node) if includes_leaf
        excludes_leaf = attr_xml.at('excludes')
        excludes = assertions(excludes_leaf.children, node) if excludes_leaf
        OpenEHR::AM::Archetype::ConstraintModel::ArchetypeSlot.new(path: node.path, node_id: node.id, rm_type_name: rm_type_name, occurrences: occurrences, includes: includes, excludes: excludes)
      end

      def occurrences(occurrence_xml)
        numeric_interval(occurrence_xml, real: false)
      end

      # Shared by occurrences()/existence/cardinality (always Integer
      # bounds) and C_REAL's range (Real bounds, via numeric_interval's
      # real: true - see xml_primitive_parsing.rb's c_real).
      def numeric_interval(occurrence_xml, real:)
        return nil if occurrence_xml.nil?

        lower_node = occurrence_xml.at('lower')
        upper_node = occurrence_xml.at('upper')
        lower_included_node = occurrence_xml.at('lower_included')
        upper_included_node = occurrence_xml.at('upper_included')
        lower_unbounded_node = occurrence_xml.at('lower_unbounded')
        upper_unbounded_node = occurrence_xml.at('upper_unbounded')

        lower = lower_node ? numeric_bound(lower_node.text, real) : nil
        upper = upper_node ? numeric_bound(upper_node.text, real) : nil
        lower_included = lower_included_node ? to_bool(lower_included_node.text) : (lower.nil? ? nil : true)
        upper_included = upper_included_node ? to_bool(upper_included_node.text) : (upper.nil? ? nil : true)
        lower_unbounded = lower_unbounded_node ? to_bool(lower_unbounded_node.text) : false
        upper_unbounded = upper_unbounded_node ? to_bool(upper_unbounded_node.text) : false

        # An occurrences element with none of its children present carries no
        # constraint at all; Interval requires at least one bound, so treat
        # this as "no occurrences data" rather than raising.
        return nil if lower.nil? && upper.nil? && !lower_unbounded && !upper_unbounded

        # Handle unbounded intervals properly
        if upper_unbounded || upper.nil?
          upper = nil
          upper_included = nil
        end

        if lower_unbounded || lower.nil?
          lower = nil
          lower_included = nil
        end

        OpenEHR::AssumedLibraryTypes::Interval.new(
          lower: lower,
          upper: upper,
          lower_included: lower_included,
          upper_included: upper_included
        )
      end

      def numeric_bound(text, real)
        real ? text.to_f : text.to_i
      end

      def cardinality(xml)
        return nil if xml.nil?

        order_node = xml.at('is_ordered')
        unique_node = xml.at('is_unique')
        interval_node = xml.at('interval')

        # No cardinality sub-elements at all means no cardinality data.
        return nil if order_node.nil? && unique_node.nil? && interval_node.nil?

        order = order_node ? to_bool(order_node.text) : false
        unique = unique_node ? to_bool(unique_node.text) : false
        interval = interval_node ? occurrences(interval_node) : nil

        OpenEHR::AM::Archetype::ConstraintModel::Cardinality.new(
          is_ordered: order,
          is_unique: unique,
          interval: interval
        )
      end

      def archetype_internal_ref(attr_xml, node)
        rm_type_name = attr_xml.at('rm_type_name').text
        target_path = attr_xml.at('target_path').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        OpenEHR::AM::Archetype::ConstraintModel::ArchetypeInternalRef.new(rm_type_name: rm_type_name, occurrences: occurrences, target_path: target_path)
      end

      def constraint_ref(attr_xml, node)
        rm_type_name = attr_xml.at('rm_type_name').text
        reference = attr_xml.at('reference').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        OpenEHR::AM::Archetype::ConstraintModel::ConstraintRef.new(rm_type_name: rm_type_name, occurrences: occurrences, reference: reference)
      end

      def assertions(attr_xml, node)
        tag_node = attr_xml.at('tag')
        tag = tag_node.nil? ? nil : tag_node.text
        string_expression = attr_xml.at('string_expression')
        string_expression = string_expression.nil? ? nil : string_expression.text
        expression_leaf = attr_xml.at 'expression'
        expression = send expression_leaf.attributes['type'].text.downcase, expression_leaf
        [OpenEHR::AM::Archetype::Assertion::Assertion.new(tag: tag, expression: expression, string_expression: string_expression)]
      end

      def expr_binary_operator(attr_xml)
        type = attr_xml.at('type').text
        operator = OpenEHR::AM::Archetype::Assertion::OperatorKind.new(value: attr_xml.at('operator').text.to_i)

        precedence_overridden = attr_xml.at('precedence_overridden').text == 'true' ? true : false
        right_operand_leaf = attr_xml.at 'right_operand'
        right_operand = send right_operand_leaf.attributes['type'].text.downcase, right_operand_leaf
        left_operand_leaf = attr_xml.at 'left_operand'
        left_operand = send left_operand_leaf.attributes['type'].text.downcase, left_operand_leaf
        OpenEHR::AM::Archetype::Assertion::ExprBinaryOperator.new(type: type, operator: operator, precedence_overridden: precedence_overridden, right_operand: right_operand, left_operand: left_operand)
      end

      def expr_unary_operator(attr_xml)
        type = attr_xml.at('type').text
        operator = OpenEHR::AM::Archetype::Assertion::OperatorKind.new(value: attr_xml.at('operator').text.to_i)
        precedence_overridden = attr_xml.at('precedence_overridden').text == 'true' ? true : false
        operand_leaf = attr_xml.at 'operand'
        operand = send operand_leaf.attributes['type'].text.downcase, operand_leaf
        OpenEHR::AM::Archetype::Assertion::ExprUnaryOperator.new(type: type, operator: operator, precedence_overridden: precedence_overridden, operand: operand)
      end

      def expr_leaf(attr_xml)
        type = attr_xml.at('type').text
        item_leaf = attr_xml.at('item')
        item = send type.downcase, item_leaf
        reference_type = attr_xml.at('reference_type').text
        OpenEHR::AM::Archetype::Assertion::ExprLeaf.new(type: type, item: item, reference_type: reference_type)
      end

      def c_primitive_object(attr_xml, node)
        rm_type_name = attr_xml.at('rm_type_name').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        item = send attr_xml.at('item')['type'].downcase, attr_xml.at('item')
        OpenEHR::AM::Archetype::ConstraintModel::CPrimitiveObject.new(rm_type_name: rm_type_name, occurrences: occurrences, node_id: node.id, item: item)
      end

      # Bare-literal ExprLeaf#item readers (type "String"/"Integer"/
      # "Real"/"Boolean", reference_type "CONSTANT") - distinct from
      # the C_STRING/C_INTEGER/... constraint-item readers in
      # xml_primitive_parsing.rb, which are dispatched to for
      # reference_type "constraint" leaves instead.
      def string(attr_xml)
        attr_xml.text
      end

      def integer(attr_xml)
        attr_xml.text.to_i
      end

      def real(attr_xml)
        attr_xml.text.to_f
      end

      def boolean(attr_xml)
        to_bool(attr_xml.text)
      end

      def to_bool(str)
        return nil if str.nil?
        str = str.text if str.respond_to?(:text)
        return true if /true/i =~ str.to_s
        return false if /false/i =~ str.to_s
        nil
      end
    end
  end
end
