require 'spec_helper'

module OpenEHR
  module Parser
    describe OPTParser do
      let(:minimum_opt_file) { File.join(File.dirname(__FILE__), './minimum_template.opt') }
      let(:parser) { OPTParser.new(minimum_opt_file) }

      # Parses a stand-alone constraint fragment the way the parser sees it:
      # namespaces stripped, so xsi:type becomes a plain `type` attribute.
      def fragment(xml)
        doc = Nokogiri::XML::Document.parse(xml)
        doc.remove_namespaces!
        doc.root
      end

      describe '#c_real' do
        context 'with a range' do
          let(:node) do
            fragment(<<~XML)
              <item xsi:type="C_REAL">
                <range>
                  <lower_included>true</lower_included>
                  <upper_included>true</upper_included>
                  <lower_unbounded>false</lower_unbounded>
                  <upper_unbounded>false</upper_unbounded>
                  <lower>0</lower>
                  <upper>2</upper>
                </range>
              </item>
            XML
          end

          it 'returns a CReal' do
            result = parser.send(:c_real, node)
            expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CReal)
          end

          it 'keeps the range bounds' do
            result = parser.send(:c_real, node)
            expect(result.range.lower).to eq 0
            expect(result.range.upper).to eq 2
          end
        end

        context 'with a list of allowed values' do
          let(:node) do
            fragment(<<~XML)
              <item xsi:type="C_REAL">
                <list>1.5</list>
                <list>2.5</list>
              </item>
            XML
          end

          it 'keeps the list as floats' do
            result = parser.send(:c_real, node)
            expect(result.list).to eq [1.5, 2.5]
          end
        end
      end

      describe '#c_duration' do
        it 'returns a CDuration for a range-constrained duration' do
          node = fragment(<<~XML)
            <item xsi:type="C_DURATION">
              <range>
                <lower_included>true</lower_included>
                <upper_included>true</upper_included>
                <lower_unbounded>false</lower_unbounded>
                <upper_unbounded>false</upper_unbounded>
                <lower>PT24H</lower>
                <upper>PT24H</upper>
              </range>
            </item>
          XML
          result = parser.send(:c_duration, node)
          expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDuration)
        end

        it 'keeps the range bounds, wrapped as DV_DURATION so valid_value? can compare durations' do
          node = fragment(<<~XML)
            <item xsi:type="C_DURATION">
              <range>
                <lower_included>true</lower_included>
                <upper_included>true</upper_included>
                <lower_unbounded>false</lower_unbounded>
                <upper_unbounded>false</upper_unbounded>
                <lower>PT1H</lower>
                <upper>PT24H</upper>
              </range>
            </item>
          XML
          result = parser.send(:c_duration, node)
          expect(result.range.lower.value).to eq 'PT1H'
          expect(result.range.upper.value).to eq 'PT24H'
          expect(result.valid_value?('PT12H')).to be true
          expect(result.valid_value?('P2D')).to be false
        end

        it 'keeps the pattern when present' do
          node = fragment('<item xsi:type="C_DURATION"><pattern>PnYnMnW</pattern></item>')
          result = parser.send(:c_duration, node)
          expect(result.pattern).to eq 'PnYnMnW'
        end
      end

      describe '#c_dv_ordinal' do
        let(:node) do
          fragment(<<~XML)
            <children xsi:type="C_DV_ORDINAL">
              <rm_type_name>DV_ORDINAL</rm_type_name>
              <occurrences>
                <lower_included>true</lower_included>
                <upper_included>true</upper_included>
                <lower_unbounded>false</lower_unbounded>
                <upper_unbounded>false</upper_unbounded>
                <lower>1</lower>
                <upper>1</upper>
              </occurrences>
              <node_id />
              <list>
                <value>1</value>
                <symbol>
                  <defining_code>
                    <terminology_id><value>local</value></terminology_id>
                    <code_string>at0115</code_string>
                  </defining_code>
                </symbol>
              </list>
              <list>
                <value>2</value>
                <symbol>
                  <defining_code>
                    <terminology_id><value>local</value></terminology_id>
                    <code_string>at0116</code_string>
                  </defining_code>
                </symbol>
              </list>
            </children>
          XML
        end

        it 'returns a CDvOrdinal' do
          result = parser.send(:c_dv_ordinal, node, Node.new)
          expect(result).to be_a(OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvOrdinal)
        end

        it 'carries the rm_type_name so downstream extraction works' do
          result = parser.send(:c_dv_ordinal, node, Node.new)
          expect(result.rm_type_name).to eq 'DV_ORDINAL'
        end

        it 'collects the ordinal values, each with its coded symbol (not bare integers - DV_ORDINAL.symbol is a DV_CODED_TEXT, needed by CDvOrdinal#valid_value?)' do
          result = parser.send(:c_dv_ordinal, node, Node.new)
          expect(result.list.map(&:value)).to eq [1, 2]
          expect(result.list.map { |o| o.symbol.defining_code.code_string }).to eq ['at0115', 'at0116']
        end
      end

      describe '#c_dv_scale' do
        let(:node) do
          fragment(<<~XML)
            <children xsi:type="C_DV_SCALE">
              <rm_type_name>DV_SCALE</rm_type_name>
              <occurrences>
                <lower_included>true</lower_included>
                <upper_included>true</upper_included>
                <lower_unbounded>false</lower_unbounded>
                <upper_unbounded>false</upper_unbounded>
                <lower>1</lower>
                <upper>1</upper>
              </occurrences>
              <node_id />
              <list>
                <value>0.5</value>
                <symbol>
                  <defining_code>
                    <terminology_id><value>local</value></terminology_id>
                    <code_string>at0115</code_string>
                  </defining_code>
                </symbol>
              </list>
              <list>
                <value>1.0</value>
                <symbol>
                  <defining_code>
                    <terminology_id><value>local</value></terminology_id>
                    <code_string>at0116</code_string>
                  </defining_code>
                </symbol>
              </list>
            </children>
          XML
        end

        it 'returns a CDvScale' do
          result = parser.send(:c_dv_scale, node, Node.new)
          expect(result).to be_a(OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvScale)
        end

        it 'carries the rm_type_name so downstream extraction works' do
          result = parser.send(:c_dv_scale, node, Node.new)
          expect(result.rm_type_name).to eq 'DV_SCALE'
        end

        it 'collects the scale values as Real numbers, each with its coded symbol' do
          result = parser.send(:c_dv_scale, node, Node.new)
          expect(result.list.map(&:value)).to eq [0.5, 1.0]
          expect(result.list.map { |o| o.symbol.defining_code.code_string }).to eq ['at0115', 'at0116']
        end
      end

      describe 'parsing a full template that uses the new constraint types' do
        let(:opt_file) { File.join(File.dirname(__FILE__), './new_constraints_template.opt') }

        # Flattens every constraint object reachable through the AOM tree so a
        # spec can assert which constraint kinds the parser actually produced.
        def collect(object, acc = [])
          acc << object
          object.attributes.each { |a| collect(a, acc) } if object.respond_to?(:attributes) && object.attributes
          object.children.each { |c| collect(c, acc) } if object.respond_to?(:children) && object.children
          collect(object.item, acc) if object.respond_to?(:item) && object.item
          acc
        end

        it 'parses without raising' do
          expect { OPTParser.new(opt_file).parse }.not_to raise_error
        end

        it 'builds CReal, CDuration and CDvOrdinal constraints from the template' do
          classes = collect(OPTParser.new(opt_file).parse.definition).map(&:class)
          expect(classes).to include(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CReal)
          expect(classes).to include(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDuration)
          expect(classes).to include(OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvOrdinal)
        end
      end

      describe '#c_dv_quantity without a property' do
        let(:node) do
          fragment(<<~XML)
            <children xsi:type="C_DV_QUANTITY">
              <rm_type_name>DV_QUANTITY</rm_type_name>
              <occurrences>
                <lower_included>true</lower_included>
                <upper_included>true</upper_included>
                <lower_unbounded>false</lower_unbounded>
                <upper_unbounded>false</upper_unbounded>
                <lower>0</lower>
                <upper>1</upper>
              </occurrences>
              <node_id />
            </children>
          XML
        end

        it 'does not raise when the property element is missing' do
          expect { parser.send(:c_dv_quantity, node, Node.new) }.not_to raise_error
        end

        it 'returns a CDvQuantity with a nil property and empty list' do
          result = parser.send(:c_dv_quantity, node, Node.new)
          expect(result).to be_a(OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvQuantity)
          expect(result.rm_type_name).to eq 'DV_QUANTITY'
          expect(result.property).to be_nil
          expect(result.list).to eq []
        end
      end

      describe '#c_dv_quantity with a fully specified constraint' do
        let(:node) do
          fragment(<<~XML)
            <children xsi:type="C_DV_QUANTITY">
              <rm_type_name>DV_QUANTITY</rm_type_name>
              <occurrences>
                <lower_included>true</lower_included>
                <upper_included>true</upper_included>
                <lower_unbounded>false</lower_unbounded>
                <upper_unbounded>false</upper_unbounded>
                <lower>1</lower>
                <upper>1</upper>
              </occurrences>
              <node_id />
              <property>
                <terminology_id><value>openehr</value></terminology_id>
                <code_string>128</code_string>
              </property>
              <list>
                <units>yr</units>
                <magnitude>
                  <lower_included>true</lower_included>
                  <upper_included>true</upper_included>
                  <lower_unbounded>false</lower_unbounded>
                  <upper_unbounded>false</upper_unbounded>
                  <lower>0.5</lower>
                  <upper>200.5</upper>
                </magnitude>
                <precision>
                  <lower_included>true</lower_included>
                  <upper_included>true</upper_included>
                  <lower_unbounded>false</lower_unbounded>
                  <upper_unbounded>false</upper_unbounded>
                  <lower>2</lower>
                  <upper>2</upper>
                </precision>
              </list>
              <assumed_value>
                <units>yr</units>
                <magnitude>8.5</magnitude>
                <precision>2</precision>
              </assumed_value>
            </children>
          XML
        end

        it 'reads the magnitude range as Real (not truncated to Integer)' do
          result = parser.send(:c_dv_quantity, node, Node.new)
          expect(result.list.first.magnitude.lower).to eq(0.5)
          expect(result.list.first.magnitude.upper).to eq(200.5)
        end

        it 'reads the precision range as Integer' do
          result = parser.send(:c_dv_quantity, node, Node.new)
          expect(result.list.first.precision.lower).to eq(2)
          expect(result.list.first.precision.upper).to eq(2)
        end

        it 'reads assumed_value as a real (non-ranged) DV_QUANTITY' do
          result = parser.send(:c_dv_quantity, node, Node.new)
          expect(result.assumed_value).to be_a(OpenEHR::RM::DataTypes::Quantity::DvQuantity)
          expect(result.assumed_value.units).to eq('yr')
          expect(result.assumed_value.magnitude).to eq(8.5)
          expect(result.assumed_value.precision).to eq(2)
        end
      end

      describe '#expr_unary_operator' do
        let(:node) do
          fragment(<<~XML)
            <expression xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="EXPR_UNARY_OPERATOR">
              <type>Boolean</type>
              <operator>2010</operator>
              <precedence_overridden>false</precedence_overridden>
              <operand xsi:type="EXPR_LEAF">
                <type>String</type>
                <item xsi:type="xsd:string">archetype_id/value</item>
                <reference_type>attribute</reference_type>
              </operand>
            </expression>
          XML
        end

        it 'returns an ExprUnaryOperator with its operand' do
          result = parser.send(:expr_unary_operator, node)
          expect(result).to be_a(OpenEHR::AM::Archetype::Assertion::ExprUnaryOperator)
          expect(result.operator.value).to eq(OpenEHR::AM::Archetype::Assertion::OperatorKind::OP_NOT)
          expect(result.operand.item).to eq('archetype_id/value')
        end
      end

      describe '#assertions with a tag' do
        let(:node) do
          fragment(<<~XML)
            <includes xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
              <tag>inv1</tag>
              <string_expression>archetype_id/value matches {/.*\.v1/}</string_expression>
              <expression xsi:type="EXPR_BINARY_OPERATOR">
                <type>Boolean</type>
                <operator>2007</operator>
                <precedence_overridden>false</precedence_overridden>
                <left_operand xsi:type="EXPR_LEAF">
                  <type>String</type>
                  <item xsi:type="xsd:string">archetype_id/value</item>
                  <reference_type>attribute</reference_type>
                </left_operand>
                <right_operand xsi:type="EXPR_LEAF">
                  <type>C_STRING</type>
                  <item xsi:type="C_STRING">
                    <pattern>.*\.v1</pattern>
                  </item>
                  <reference_type>constraint</reference_type>
                </right_operand>
              </expression>
            </includes>
          XML
        end

        it 'reads the tag onto the Assertion' do
          result = parser.send(:assertions, node.children, Node.new)
          expect(result.first.tag).to eq('inv1')
        end
      end
    end
  end
end
