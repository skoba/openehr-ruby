module OpenEHR
  module Parser
    # openEHR Archetype Profile domain-type readers (C_CODE_PHRASE,
    # C_DV_QUANTITY, C_DV_ORDINAL, C_DV_SCALE, C_DV_STATE), shared
    # between OPTParser and XMLArchetypeParser. Extracted from
    # opt_parser.rb without behavior changes, except: C_DV_QUANTITY now
    # reads assumed_value (previously ignored) and its magnitude range
    # reads Float bounds instead of Integer (precision stays Integer -
    # see numeric_interval in xml_constraint_parsing.rb).
    module XMLDomainTypeParsing
      private

      def c_code_phrase(attr_xml, node)
        OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodePhrase.new(
          code_phrase_constraint_args(attr_xml, node)
        )
      end

      def c_code_reference(attr_xml, node)
        args = code_phrase_constraint_args(attr_xml, node)
        args[:code_list] = nil if args[:code_list] && args[:code_list].empty?
        uri = attr_xml.at('referenceSetUri')&.text&.strip
        args[:reference_set_uri] = uri unless uri.nil? || uri.empty?
        OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodeReference.new(args)
      end

      def code_phrase_constraint_args(attr_xml, node)
        terminology_id_node = attr_xml.at('terminology_id/value')
        terminology_id = terminology_id_node ? OpenEHR::RM::Support::Identification::TerminologyID.new(value: terminology_id_node.text.strip) : nil

        code_list_nodes = attr_xml.xpath('code_list')
        code_list = code_list_nodes.map { |code_node| code_node.text.strip }
        code_list = [code_list.first] if code_list.size == 1 && code_list.first.empty?

        occurrences_node = attr_xml.at('occurrences')
        occurrences_obj = occurrences_node ? occurrences(occurrences_node) : nil

        {
          terminology_id: terminology_id,
          code_list: code_list,
          path: node.path,
          occurrences: occurrences_obj,
          rm_type_name: 'CODE_PHRASE'
        }
      end

      # The <property> element is optional in real templates; return nil rather
      # than dereferencing missing terminology/code nodes.
      def property_code_phrase(property_xml)
        return nil if property_xml.nil?
        terminology_node = property_xml.at('terminology_id/value')
        code_node = property_xml.at('code_string')
        return nil if terminology_node.nil? || code_node.nil?
        terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: terminology_node.text)
        OpenEHR::RM::DataTypes::Text::CodePhrase.new(terminology_id: terminology_id, code_string: code_node.text)
      end

      def c_dv_quantity(attr_xml, node)
        rm_type_name = attr_xml.at('rm_type_name').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        property = property_code_phrase(attr_xml.at('property'))
        list = attr_xml.xpath('.//list').map { |element| c_quantity_item(element) }
        assumed_value = dv_quantity_assumed_value(attr_xml.at('assumed_value'))
        OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvQuantity.new(
          rm_type_name: rm_type_name, occurrences: occurrences, list: list, property: property, assumed_value: assumed_value
        )
      end

      def c_quantity_item(element)
        units = element.at('units').text if element.at('units')
        magnitude = numeric_interval(element.at('magnitude'), real: true) if element.at('magnitude')
        precision = numeric_interval(element.at('precision'), real: false) if element.at('precision')
        OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CQuantityItem.new(magnitude: magnitude, precision: precision, units: units)
      end

      # assumed_value is a real DV_QUANTITY (plain magnitude/precision,
      # not a range), matching XMLSerializer#emit_dv_quantity_assumed_value.
      def dv_quantity_assumed_value(element)
        return nil if element.nil?

        units = element.at('units')&.text
        magnitude_node = element.at('magnitude')
        magnitude = magnitude_node ? magnitude_node.text.to_f : nil
        precision_node = element.at('precision')
        precision = precision_node ? precision_node.text.to_i : nil
        OpenEHR::RM::DataTypes::Quantity::DvQuantity.new(units: units, magnitude: magnitude, precision: precision)
      end

      def c_dv_ordinal(attr_xml, node)
        rm_type_name = attr_xml.at('rm_type_name').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        list = attr_xml.xpath('list').map { |element| dv_ordinal_item(element) }.compact
        OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvOrdinal.new(rm_type_name: rm_type_name, occurrences: occurrences, list: list)
      end

      # DV_ORDINAL.symbol is spec'd as DV_CODED_TEXT; the OPT XML only
      # carries a defining_code (terminology_id + code_string), so the
      # DvCodedText's own value is set to that same code_string (there
      # is no separate display text in this element).
      def dv_ordinal_item(element)
        value_node = element.at('value')
        return nil unless value_node && !value_node.text.empty?

        code_phrase = property_code_phrase(element.at('symbol/defining_code'))
        return nil if code_phrase.nil?

        symbol = OpenEHR::RM::DataTypes::Text::DvCodedText.new(value: code_phrase.code_string, defining_code: code_phrase)
        OpenEHR::RM::DataTypes::Quantity::DvOrdinal.new(value: value_node.text.to_i, symbol: symbol)
      end

      def c_dv_scale(attr_xml, node)
        rm_type_name = attr_xml.at('rm_type_name').text
        occurrences = occurrences(attr_xml.at('occurrences'))
        list = attr_xml.xpath('list').map { |element| dv_scale_item(element) }.compact
        OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvScale.new(rm_type_name: rm_type_name, occurrences: occurrences, list: list)
      end

      # Same XML shape as C_DV_ORDINAL's list items, but DV_SCALE.value
      # is Real rather than Integer.
      def dv_scale_item(element)
        value_node = element.at('value')
        return nil unless value_node && !value_node.text.empty?

        code_phrase = property_code_phrase(element.at('symbol/defining_code'))
        return nil if code_phrase.nil?

        symbol = OpenEHR::RM::DataTypes::Text::DvCodedText.new(value: code_phrase.code_string, defining_code: code_phrase)
        OpenEHR::RM::DataTypes::Quantity::DvScale.new(value: value_node.text.to_f, symbol: symbol)
      end

      # No .opt fixture in this gem's corpus uses a C_DV_STATE (state
      # machine) constraint, so its actual OPT XML shape is unverified,
      # and XMLSerializer itself can't emit one to a standalone
      # archetype either (ADL 1.4 has no grammar rule for it) - raising
      # a clear, documented error here is safer than guessing at
      # element names and risking a silently wrong StateMachine.
      def c_dv_state(_attr_xml, _node)
        raise NotImplementedError, 'OPTParser does not yet support C_DV_STATE (state machine) constraints'
      end
    end
  end
end
