require 'spec_helper'

module OpenEHR
  module Parser
    describe OPTParser do
      describe 'error handling and robustness' do
        context 'file handling errors' do
          it 'should raise error for non-existent file' do
            expect {
              OPTParser.new('/non/existent/file.opt').parse
            }.to raise_error
          end
        end

        context 'malformed XML handling' do
          let(:temp_file) { Tempfile.new(['malformed', '.opt']) }
          
          after { temp_file.unlink }

          it 'should handle empty file gracefully' do
            temp_file.write('')
            temp_file.close
            
            expect {
              OPTParser.new(temp_file.path).parse
            }.to raise_error
          end

          it 'should handle invalid XML gracefully' do
            temp_file.write('<?xml version="1.0"?><invalid><unclosed>')
            temp_file.close
            
            expect {
              OPTParser.new(temp_file.path).parse
            }.to raise_error
          end
        end

        context 'missing required elements' do
          let(:temp_file) { Tempfile.new(['minimal', '.opt']) }
          
          after { temp_file.unlink }

          it 'should handle missing template_id' do
            minimal_xml = <<~XML
              <?xml version="1.0"?>
              <template>
                <language>
                  <terminology_id><value>ISO_639-1</value></terminology_id>
                  <code_string>en</code_string>
                </language>
                <description>
                  <original_author>Test</original_author>
                  <lifecycle_state>Initial</lifecycle_state>
                  <details>
                    <language>
                      <terminology_id><value>ISO_639-1</value></terminology_id>
                      <code_string>en</code_string>
                    </language>
                    <purpose>Test</purpose>
                  </details>
                </description>
                <concept>Test</concept>
                <definition>
                  <rm_type_name>COMPOSITION</rm_type_name>
                  <node_id>at0000</node_id>
                  <occurrences>
                    <lower>1</lower>
                    <upper>1</upper>
                    <lower_included>true</lower_included>
                    <upper_included>true</upper_included>
                    <lower_unbounded>false</lower_unbounded>
                    <upper_unbounded>false</upper_unbounded>
                  </occurrences>
                  <archetype_id><value>test.v1</value></archetype_id>
                  <attributes type="C_SINGLE_ATTRIBUTE">
                    <rm_attribute_name>category</rm_attribute_name>
                    <existence>
                      <lower>1</lower>
                      <upper>1</upper>
                      <lower_included>true</lower_included>
                      <upper_included>true</upper_included>
                    </existence>
                    <children type="C_COMPLEX_OBJECT">
                      <rm_type_name>DV_CODED_TEXT</rm_type_name>
                      <occurrences>
                        <lower>1</lower>
                        <upper>1</upper>
                        <lower_included>true</lower_included>
                        <upper_included>true</upper_included>
                      </occurrences>
                    </children>
                  </attributes>
                </definition>
              </template>
            XML
            
            temp_file.write(minimal_xml)
            temp_file.close
            
            expect {
              OPTParser.new(temp_file.path).parse
            }.to raise_error(ArgumentError, 'template_id is mandatory for operational template')
          end

          it 'should handle missing uid gracefully' do
            minimal_xml = <<~XML
              <?xml version="1.0"?>
              <template>
                <language>
                  <terminology_id><value>ISO_639-1</value></terminology_id>
                  <code_string>en</code_string>
                </language>
                <template_id><value>test.template.v1</value></template_id>
                <concept>Test</concept>
                <description>
                  <original_author>Test</original_author>
                  <lifecycle_state>Initial</lifecycle_state>
                  <details>
                    <language>
                      <terminology_id><value>ISO_639-1</value></terminology_id>
                      <code_string>en</code_string>
                    </language>
                    <purpose>Test</purpose>
                  </details>
                </description>
                <definition>
                  <rm_type_name>COMPOSITION</rm_type_name>
                  <node_id>at0000</node_id>
                  <occurrences>
                    <lower>1</lower>
                    <upper>1</upper>
                    <lower_included>true</lower_included>
                    <upper_included>true</upper_included>
                    <lower_unbounded>false</lower_unbounded>
                    <upper_unbounded>false</upper_unbounded>
                  </occurrences>
                  <archetype_id><value>test.v1</value></archetype_id>
                  <attributes type="C_SINGLE_ATTRIBUTE">
                    <rm_attribute_name>category</rm_attribute_name>
                    <existence>
                      <lower>1</lower>
                      <upper>1</upper>
                      <lower_included>true</lower_included>
                      <upper_included>true</upper_included>
                    </existence>
                    <children type="C_COMPLEX_OBJECT">
                      <rm_type_name>DV_CODED_TEXT</rm_type_name>
                      <occurrences>
                        <lower>1</lower>
                        <upper>1</upper>
                        <lower_included>true</lower_included>
                        <upper_included>true</upper_included>
                      </occurrences>
                    </children>
                  </attributes>
                </definition>
              </template>
            XML
            
            temp_file.write(minimal_xml)
            temp_file.close
            
            # Should not raise error, uid is optional
            expect {
              result = OPTParser.new(temp_file.path).parse
              expect(result).to be_a(OpenEHR::AM::Template::OperationalTemplate)
            }.not_to raise_error
          end
        end

        context 'robust parsing with missing optional elements' do
          let(:parser) { OPTParser.new(File.join(File.dirname(__FILE__), './minimum_template.opt')) }
          
          before { parser.parse }

          describe 'handling missing nodes in methods' do
            it 'should handle missing nodes in description_other_details' do
              xml = double('xml')
              allow(xml).to receive(:xpath).and_return([])
              
              result = parser.send(:description_other_details)
              expect(result).to eq({})
            end

            it 'should handle missing occurrence data' do
              xml = double('xml')
              allow(xml).to receive(:at).and_return(nil)
              
              result = parser.send(:occurrences, xml)
              expect(result).to be_nil
            end

            it 'should handle missing cardinality data' do
              xml = double('xml')
              allow(xml).to receive(:at).and_return(nil)
              
              result = parser.send(:cardinality, xml)
              expect(result).to be_nil
            end
          end

          describe 'robust XML navigation' do
            it 'should handle missing text nodes gracefully' do
              xml = double('xml')
              allow(xml).to receive(:xpath).with('/nonexistent/path').and_return(double(text: ''))
              
              result = parser.send(:text_on_path, xml, '/nonexistent/path')
              expect(result).to eq('')
            end

            it 'should handle nil nodes in to_bool' do
              result = parser.send(:to_bool, nil)
              expect(result).to be_nil
            end

            it 'should handle invalid boolean strings' do
              result = parser.send(:to_bool, 'maybe')
              expect(result).to be_nil
            end
          end

          describe 'primitive constraint robustness' do
            it 'should handle missing pattern in c_date' do
              xml = double('xml')
              allow(xml).to receive(:at).with('pattern').and_return(nil)
              allow(xml).to receive(:at).with('range').and_return(nil)
              
              result = parser.send(:c_date, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDate)
              expect(result.pattern).to be_nil
            end

            it 'should handle missing pattern in c_date_time' do
              xml = double('xml')
              allow(xml).to receive(:at).with('pattern').and_return(nil)
              allow(xml).to receive(:at).with('range').and_return(nil)
              
              result = parser.send(:c_date_time, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDateTime)
              expect(result.pattern).to be_nil
            end

            it 'should handle missing range and list in c_integer' do
              xml = double('xml')
              allow(xml).to receive(:at).with('range').and_return(nil)
              allow(xml).to receive(:xpath).with('list').and_return([])
              
              result = parser.send(:c_integer, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CInteger)
              expect(result.list).to be_nil
            end

            it 'should handle missing boolean attributes in c_boolean' do
              xml = double('xml')
              allow(xml).to receive(:at).with('true_valid').and_return(nil)
              allow(xml).to receive(:at).with('false_valid').and_return(nil)
              allow(xml).to receive(:at).with('assumed_value').and_return(nil)
              
              result = parser.send(:c_boolean, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CBoolean)
              expect(result.true_valid).to be_nil
              expect(result.false_valid).to be_nil
              expect(result.assumed_value).to be_nil
            end
          end

          describe 'complex constraint robustness' do
            it 'should handle missing includes and excludes in archetype_slot' do
              xml = double('xml')
              node = Node.new
              
              allow(xml).to receive(:at).with('node_id').and_return(double(text: 'at0001'))
              allow(xml).to receive(:at).with('rm_type_name').and_return(double(text: 'CLUSTER'))
              allow(xml).to receive(:at).with('occurrences').and_return(double('occurrences'))
              allow(xml).to receive(:at).with('includes').and_return(nil)
              allow(xml).to receive(:at).with('excludes').and_return(nil)
              allow(parser).to receive(:occurrences).and_return(double('interval'))
              
              result = parser.send(:archetype_slot, xml, node)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::ArchetypeSlot)
              expect(result.includes).to be_nil
              expect(result.excludes).to be_nil
            end

            it 'should handle empty list in c_dv_quantity' do
              xml = double('xml')
              node = Node.new
              
              property_xml = double('property')
              allow(xml).to receive(:at).with('rm_type_name').and_return(double(text: 'DV_QUANTITY'))
              allow(xml).to receive(:at).with('occurrences').and_return(double('occurrences'))
              allow(xml).to receive(:at).with('property').and_return(property_xml)
              allow(property_xml).to receive(:at).with('terminology_id/value').and_return(double(text: 'openehr'))
              allow(property_xml).to receive(:at).with('code_string').and_return(double(text: '382'))
              allow(xml).to receive(:xpath).with('.//list').and_return([])
              allow(parser).to receive(:occurrences).and_return(double('interval'))
              
              result = parser.send(:c_dv_quantity, xml, node)
              expect(result).to be_a(OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvQuantity)
              expect(result.list).to eq([])
            end
          end
        end
      end
    end
  end
end