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

        it 'collects the ordinal values' do
          result = parser.send(:c_dv_ordinal, node, Node.new)
          expect(result.list).to eq [1, 2]
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
    end
  end
end
