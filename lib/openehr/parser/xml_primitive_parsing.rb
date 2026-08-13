module OpenEHR
  module Parser
    # The 8 C_PRIMITIVE readers (boolean/string/integer/real/date/
    # date_time/time/duration), shared between OPTParser and
    # XMLArchetypeParser - both read a <item xsi:type="C_*">-wrapped
    # element with the same internal shape. Extracted from opt_parser.rb
    # without behavior changes, except C_REAL's range now reads Float
    # bounds instead of silently truncating them to Integer via
    # numeric_interval(real: true) (see xml_constraint_parsing.rb).
    module XMLPrimitiveParsing
      private

      def c_date(xml)
        pattern = xml.at('pattern')
        range = xml.at('range')
        if pattern
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDate.new(pattern: pattern.text)
        elsif range
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDate.new(range: occurrences(range))
        else
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDate.new
        end
      end

      def c_date_time(xml)
        pattern = xml.at('pattern')
        range = xml.at('range')
        if pattern
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDateTime.new(pattern: pattern.text)
        elsif range
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDateTime.new(range: occurrences(range))
        else
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDateTime.new
        end
      end

      def c_integer(xml)
        range = xml.at('range')
        list = xml.xpath('list')
        if range
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CInteger.new(range: occurrences(range))
        elsif !list.empty?
          list_values = list.map { |item| item.text.to_i }
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CInteger.new(list: list_values)
        else
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CInteger.new
        end
      end

      def c_real(xml)
        range = xml.at('range')
        list = xml.xpath('list')
        if range
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CReal.new(range: numeric_interval(range, real: true))
        elsif !list.empty?
          list_values = list.map { |item| item.text.to_f }
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CReal.new(list: list_values)
        else
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CReal.new
        end
      end

      def c_duration(xml)
        pattern = xml.at('pattern')
        range_xml = xml.at('range')
        list = xml.xpath('list')
        if pattern
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDuration.new(pattern: pattern.text)
        elsif range_xml
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDuration.new(range: duration_range(range_xml))
        elsif !list.empty?
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDuration.new(list: list.map(&:text))
        else
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDuration.new
        end
      end

      # A C_DURATION range's bounds are ISO8601 duration strings (e.g.
      # PT24H), not plain numbers, so occurrences() (built for numeric
      # Interval bounds) doesn't apply here; wrap each bound as a
      # DV_DURATION instead, matching what CDuration#valid_value?
      # already expects its range bounds to be.
      def duration_range(range_xml)
        lower = duration_bound(range_xml.at('lower'), range_xml.at('lower_unbounded'))
        upper = duration_bound(range_xml.at('upper'), range_xml.at('upper_unbounded'))
        return nil if lower.nil? && upper.nil?

        OpenEHR::AssumedLibraryTypes::Interval.new(
          lower: lower, upper: upper,
          lower_included: lower.nil? ? nil : bool_node(range_xml.at('lower_included'), true),
          upper_included: upper.nil? ? nil : bool_node(range_xml.at('upper_included'), true))
      end

      def duration_bound(value_node, unbounded_node)
        return nil if bool_node(unbounded_node, false)
        return nil if value_node.nil? || value_node.text.empty?

        OpenEHR::RM::DataTypes::Quantity::DateTime::DvDuration.new(value: value_node.text)
      end

      def bool_node(node, default)
        node ? to_bool(node.text) : default
      end

      def c_time(xml)
        pattern = xml.at('pattern')
        range = xml.at('range')
        if pattern
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CTime.new(pattern: pattern.text)
        elsif range
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CTime.new(range: occurrences(range))
        else
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CTime.new
        end
      end

      def c_boolean(xml)
        true_valid = xml.at('true_valid')
        false_valid = xml.at('false_valid')
        assumed_value = xml.at('assumed_value')

        true_valid_value = true_valid ? to_bool(true_valid.text) : nil
        false_valid_value = false_valid ? to_bool(false_valid.text) : nil
        assumed_value_value = assumed_value ? to_bool(assumed_value.text) : nil

        OpenEHR::AM::Archetype::ConstraintModel::Primitive::CBoolean.new(
          true_valid: true_valid_value,
          false_valid: false_valid_value,
          assumed_value: assumed_value_value
        )
      end

      def c_string(attr_xml)
        if attr_xml.at('pattern')
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CString.new(pattern: attr_xml.at('pattern').text)
        else
          list = attr_xml.xpath('.//list').map do |str|
            str.text
          end
          OpenEHR::AM::Archetype::ConstraintModel::Primitive::CString.new(list: list)
        end
      end
    end
  end
end
