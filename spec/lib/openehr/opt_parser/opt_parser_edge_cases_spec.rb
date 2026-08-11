require 'spec_helper'

module OpenEHR
  module Parser
    describe OPTParser do
      let(:minimum_opt_file) { File.join(File.dirname(__FILE__), './minimum_template.opt') }
      let(:parser) { OPTParser.new(minimum_opt_file) }

      describe 'edge cases and error handling' do
        context 'initialization' do
          it 'should store filename correctly' do
            expect(parser.filename).to eq(minimum_opt_file)
          end
        end

        context 'private helper methods' do
          let(:opt) { parser.parse }

          describe '#empty_then_nil' do
            it 'should return nil for empty string' do
              result = parser.send(:empty_then_nil, '')
              expect(result).to be_nil
            end

            it 'should return value for non-empty string' do
              result = parser.send(:empty_then_nil, 'test')
              expect(result).to eq('test')
            end
          end

          describe '#to_bool' do
            it 'should convert "true" to true' do
              result = parser.send(:to_bool, 'true')
              expect(result).to be true
            end

            it 'should convert "false" to false' do
              result = parser.send(:to_bool, 'false')
              expect(result).to be false
            end

            it 'should convert "TRUE" to true (case insensitive)' do
              result = parser.send(:to_bool, 'TRUE')
              expect(result).to be true
            end

            it 'should convert "FALSE" to false (case insensitive)' do
              result = parser.send(:to_bool, 'FALSE')
              expect(result).to be false
            end

            it 'should return nil for invalid string' do
              result = parser.send(:to_bool, 'invalid')
              expect(result).to be_nil
            end

            it 'should handle nil input' do
              result = parser.send(:to_bool, nil)
              expect(result).to be_nil
            end

            it 'should handle node objects with text method' do
              node = double('node', text: 'true')
              result = parser.send(:to_bool, node)
              expect(result).to be true
            end
          end

          describe '#string' do
            it 'should extract text from XML node' do
              xml = double('xml', text: 'test string')
              result = parser.send(:string, xml)
              expect(result).to eq('test string')
            end
          end

          describe '#text_on_path' do
            before { parser.parse } # Initialize @opt

            it 'should extract text from XML path' do
              result = parser.send(:text_on_path, parser.instance_variable_get(:@opt), '/template/concept')
              expect(result).to eq('minimum template')
            end
          end
        end

        context 'Node class' do
          describe 'standalone node' do
            let(:node) { Node.new }

            it 'should be root by default' do
              expect(node.root?).to be true
            end

            it 'should have / as default path' do
              expect(node.path).to eq('/')
            end

            it 'should have no parent' do
              expect(node.parent).to be_nil
            end
          end

          describe 'child node' do
            let(:parent_node) { Node.new }
            let(:child_node) { Node.new(parent_node) }

            it 'should not be root' do
              expect(child_node.root?).to be false
            end

            it 'should have parent' do
              expect(child_node.parent).to eq(parent_node)
            end

            it 'should allow setting id and path' do
              child_node.id = 'at0001'
              child_node.path = '/test/path'
              expect(child_node.id).to eq('at0001')
              expect(child_node.path).to eq('/test/path')
            end
          end
        end

        context 'primitive constraint methods' do
          before { parser.parse } # Initialize @opt

          describe '#c_string with pattern' do
            it 'should create CString with pattern' do
              xml = double('xml')
              pattern_node = double('pattern', text: 'test.*pattern')
              allow(xml).to receive(:at).with('pattern').and_return(pattern_node)
              allow(xml).to receive(:xpath).with('.//list').and_return([])

              result = parser.send(:c_string, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CString)
              expect(result.pattern).to eq('test.*pattern')
            end
          end

          describe '#c_string with list' do
            it 'should create CString with list' do
              xml = double('xml')
              allow(xml).to receive(:at).with('pattern').and_return(nil)
              
              list_item1 = double('list_item', text: 'item1')
              list_item2 = double('list_item', text: 'item2')
              allow(xml).to receive(:xpath).with('.//list').and_return([list_item1, list_item2])

              result = parser.send(:c_string, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CString)
              expect(result.list).to eq(['item1', 'item2'])
            end
          end

          describe '#c_date with pattern' do
            it 'should create CDate with pattern' do
              xml = double('xml')
              pattern_node = double('pattern', text: 'yyyy-mm-dd')
              allow(xml).to receive(:at).with('pattern').and_return(pattern_node)
              allow(xml).to receive(:at).with('range').and_return(nil)

              result = parser.send(:c_date, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDate)
              expect(result.pattern).to eq('yyyy-mm-dd')
            end
          end

          describe '#c_date_time with pattern' do
            it 'should create CDateTime with pattern' do
              xml = double('xml')
              pattern_node = double('pattern', text: 'yyyy-mm-ddTHH:MM:SS')
              allow(xml).to receive(:at).with('pattern').and_return(pattern_node)
              allow(xml).to receive(:at).with('range').and_return(nil)

              result = parser.send(:c_date_time, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDateTime)
              expect(result.pattern).to eq('yyyy-mm-ddTHH:MM:SS')
            end
          end

          describe '#c_integer with list' do
            it 'should create CInteger with list' do
              xml = double('xml')
              allow(xml).to receive(:at).with('range').and_return(nil)
              
              list_item1 = double('list_item', text: '1')
              list_item2 = double('list_item', text: '5')
              allow(xml).to receive(:xpath).with('list').and_return([list_item1, list_item2])

              result = parser.send(:c_integer, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CInteger)
              expect(result.list).to eq([1, 5])
            end
          end

          describe '#c_boolean with all values' do
            it 'should create CBoolean with specific values' do
              xml = double('xml')
              true_valid_node = double('true_valid', text: 'true')
              false_valid_node = double('false_valid', text: 'false')
              assumed_value_node = double('assumed_value', text: 'true')
              
              allow(xml).to receive(:at).with('true_valid').and_return(true_valid_node)
              allow(xml).to receive(:at).with('false_valid').and_return(false_valid_node)
              allow(xml).to receive(:at).with('assumed_value').and_return(assumed_value_node)

              result = parser.send(:c_boolean, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::Primitive::CBoolean)
              expect(result.true_valid).to be true
              expect(result.false_valid).to be false
              expect(result.assumed_value).to be true
            end
          end
        end

        context 'occurrence and cardinality edge cases' do
          before { parser.parse }

          describe '#occurrences with nil input' do
            it 'should return nil for nil input' do
              result = parser.send(:occurrences, nil)
              expect(result).to be_nil
            end
          end

          describe '#cardinality with nil input' do
            it 'should return nil for nil input' do
              result = parser.send(:cardinality, nil)
              expect(result).to be_nil
            end
          end

          describe '#occurrences with unbounded values' do
            it 'should handle upper unbounded' do
              xml = double('xml')
              allow(xml).to receive(:at).with('lower').and_return(double(text: '0'))
              allow(xml).to receive(:at).with('upper').and_return(nil)
              allow(xml).to receive(:at).with('lower_included').and_return(double(text: 'true'))
              allow(xml).to receive(:at).with('upper_included').and_return(nil)
              allow(xml).to receive(:at).with('lower_unbounded').and_return(double(text: 'false'))
              allow(xml).to receive(:at).with('upper_unbounded').and_return(double(text: 'true'))

              result = parser.send(:occurrences, xml)
              expect(result.lower).to eq(0)
              expect(result.upper).to be_nil
              expect(result.upper_included?).to be_nil
            end
          end
        end
      end

      context 'template validation methods' do
        let(:opt) { parser.parse }

        describe 'operational template validation' do
          it 'should be a valid operational template' do
            expect(opt.is_valid_operational_template?).to be true
          end

          it 'should provide referenced archetype ids' do
            expect(opt.referenced_archetype_ids).to be_an(Array)
            expect(opt.referenced_archetype_ids.size).to be > 0
          end

          it 'should return terminology for existing archetype' do
            archetype_id = opt.referenced_archetype_ids.first
            terminology = opt.terminology_for_archetype(archetype_id)
            expect(terminology).not_to be_nil
          end

          it 'should return nil for non-existing archetype' do
            terminology = opt.terminology_for_archetype('non.existing.archetype.v1')
            expect(terminology).to be_nil
          end
        end
      end
    end
  end
end