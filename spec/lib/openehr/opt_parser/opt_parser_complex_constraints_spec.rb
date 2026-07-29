require 'spec_helper'

module OpenEHR
  module Parser
    describe OPTParser do
      let(:minimum_opt_file) { File.join(File.dirname(__FILE__), './minimum_template.opt') }
      let(:parser) { OPTParser.new(minimum_opt_file) }

      describe 'complex constraint parsing' do
        before { parser.parse } # Initialize @opt

        context 'constraint_ref parsing' do
          it 'should parse constraint reference' do
            xml = double('xml')
            node = Node.new
            
            rm_type_node = double('rm_type', text: 'DV_TEXT')
            reference_node = double('reference', text: 'ac0001')
            occurrences_xml = double('occurrences')
            
            allow(xml).to receive(:at).with('rm_type_name').and_return(rm_type_node)
            allow(xml).to receive(:at).with('reference').and_return(reference_node)
            allow(xml).to receive(:at).with('occurrences').and_return(occurrences_xml)
            allow(parser).to receive(:occurrences).with(occurrences_xml).and_return(double('interval'))

            result = parser.send(:constraint_ref, xml, node)
            expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::ConstraintRef)
            expect(result.rm_type_name).to eq('DV_TEXT')
            expect(result.reference).to eq('ac0001')
          end
        end

        context 'archetype_slot parsing' do
          it 'should parse archetype slot with includes' do
            xml = double('xml')
            node = Node.new
            
            node_id_node = double('node_id', text: 'at0001')
            rm_type_node = double('rm_type', text: 'CLUSTER')
            occurrences_xml = double('occurrences')
            includes_xml = double('includes')
            
            allow(xml).to receive(:at).with('node_id').and_return(node_id_node)
            allow(xml).to receive(:at).with('rm_type_name').and_return(rm_type_node)
            allow(xml).to receive(:at).with('occurrences').and_return(occurrences_xml)
            allow(xml).to receive(:at).with('includes').and_return(includes_xml)
            allow(xml).to receive(:at).with('excludes').and_return(nil)
            
            allow(parser).to receive(:occurrences).with(occurrences_xml).and_return(double('interval'))
            allow(parser).to receive(:assertions).with(anything, node).and_return([double('assertion')])
            allow(includes_xml).to receive(:children).and_return([double('child')])

            result = parser.send(:archetype_slot, xml, node)
            expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::ArchetypeSlot)
            expect(result.node_id).to eq('at0001')
            expect(result.rm_type_name).to eq('CLUSTER')
          end

          it 'should parse archetype slot with excludes' do
            xml = double('xml')
            node = Node.new
            
            node_id_node = double('node_id', text: 'at0001')
            rm_type_node = double('rm_type', text: 'CLUSTER')
            occurrences_xml = double('occurrences')
            excludes_xml = double('excludes')
            
            allow(xml).to receive(:at).with('node_id').and_return(node_id_node)
            allow(xml).to receive(:at).with('rm_type_name').and_return(rm_type_node)
            allow(xml).to receive(:at).with('occurrences').and_return(occurrences_xml)
            allow(xml).to receive(:at).with('includes').and_return(nil)
            allow(xml).to receive(:at).with('excludes').and_return(excludes_xml)
            
            allow(parser).to receive(:occurrences).with(occurrences_xml).and_return(double('interval'))
            allow(parser).to receive(:assertions).with(anything, node).and_return([double('assertion')])
            allow(excludes_xml).to receive(:children).and_return([double('child')])

            result = parser.send(:archetype_slot, xml, node)
            expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::ArchetypeSlot)
            expect(result.excludes).not_to be_nil
          end
        end

        context 'assertion parsing' do
          it 'should parse assertions with string expression and expression' do
            xml = double('xml')
            node = Node.new
            
            string_expr_node = double('string_expr', text: 'archetype_id/value matches {/.*/}')
            expression_xml = double('expression')
            
            allow(xml).to receive(:at).with('string_expression').and_return(string_expr_node)
            allow(xml).to receive(:at).with('expression').and_return(expression_xml)
            allow(expression_xml).to receive(:attributes).and_return({'type' => double(text: 'EXPR_BINARY_OPERATOR')})
            allow(parser).to receive(:expr_binary_operator).with(expression_xml).and_return(double('binary_op'))

            result = parser.send(:assertions, xml, node)
            expect(result).to be_an(Array)
            expect(result.size).to eq(1)
            expect(result.first).to be_a(OpenEHR::AM::Archetype::Assertion::Assertion)
          end

          it 'should parse assertions without string expression' do
            xml = double('xml')
            node = Node.new
            
            expression_xml = double('expression')
            
            allow(xml).to receive(:at).with('string_expression').and_return(nil)
            allow(xml).to receive(:at).with('expression').and_return(expression_xml)
            allow(expression_xml).to receive(:attributes).and_return({'type' => double(text: 'EXPR_LEAF')})
            allow(parser).to receive(:expr_leaf).with(expression_xml).and_return(double('leaf'))

            result = parser.send(:assertions, xml, node)
            expect(result).to be_an(Array)
            expect(result.size).to eq(1)
            expect(result.first.string_expression).to be_nil
          end
        end

        context 'expression parsing' do
          describe '#expr_binary_operator' do
            it 'should parse binary operator expression' do
              xml = double('xml')
              
              type_node = double('type', text: 'Boolean')
              operator_node = double('operator', text: '2007')
              precedence_node = double('precedence', text: 'false')
              left_operand_xml = double('left_operand')
              right_operand_xml = double('right_operand')
              
              allow(xml).to receive(:at).with('type').and_return(type_node)
              allow(xml).to receive(:at).with('operator').and_return(operator_node)
              allow(xml).to receive(:at).with('precedence_overridden').and_return(precedence_node)
              allow(xml).to receive(:at).with('left_operand').and_return(left_operand_xml)
              allow(xml).to receive(:at).with('right_operand').and_return(right_operand_xml)
              
              allow(left_operand_xml).to receive(:attributes).and_return({'type' => double(text: 'EXPR_LEAF')})
              allow(right_operand_xml).to receive(:attributes).and_return({'type' => double(text: 'EXPR_LEAF')})
              allow(parser).to receive(:expr_leaf).and_return(double('leaf'))

              result = parser.send(:expr_binary_operator, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::Assertion::ExprBinaryOperator)
              expect(result.type).to eq('Boolean')
              expect(result.precedence_overridden).to be false
            end
          end

          describe '#expr_leaf' do
            it 'should parse leaf expression' do
              xml = double('xml')
              
              type_node = double('type', text: 'String')
              item_xml = double('item')
              reference_type_node = double('reference_type', text: 'attribute')
              
              allow(xml).to receive(:at).with('type').and_return(type_node)
              allow(xml).to receive(:at).with('item').and_return(item_xml)
              allow(xml).to receive(:at).with('reference_type').and_return(reference_type_node)
              allow(parser).to receive(:string).with(item_xml).and_return('test_string')

              result = parser.send(:expr_leaf, xml)
              expect(result).to be_a(OpenEHR::AM::Archetype::Assertion::ExprLeaf)
              expect(result.type).to eq('String')
              expect(result.reference_type).to eq('attribute')
            end
          end
        end

        context 'primitive object parsing' do
          it 'should parse primitive object' do
            xml = double('xml')
            node = Node.new
            node.id = 'at0001'
            
            rm_type_node = double('rm_type', text: 'STRING')
            occurrences_xml = double('occurrences')
            item_xml = double('item')
            
            allow(xml).to receive(:at).with('rm_type_name').and_return(rm_type_node)
            allow(xml).to receive(:at).with('occurrences').and_return(occurrences_xml)
            allow(xml).to receive(:at).with('item').and_return(item_xml)
            allow(item_xml).to receive(:[]).with('type').and_return('C_STRING')
            
            allow(parser).to receive(:occurrences).with(occurrences_xml).and_return(double('interval'))
            allow(parser).to receive(:c_string).with(item_xml).and_return(double('c_string'))

            result = parser.send(:c_primitive_object, xml, node)
            expect(result).to be_a(OpenEHR::AM::Archetype::ConstraintModel::CPrimitiveObject)
            expect(result.rm_type_name).to eq('STRING')
            expect(result.node_id).to eq('at0001')
          end
        end

        context 'c_dv_quantity parsing' do
          it 'should parse CDvQuantity with multiple units' do
            xml = double('xml')
            node = Node.new
            
            rm_type_node = double('rm_type', text: 'DV_QUANTITY')
            occurrences_xml = double('occurrences')
            property_xml = double('property')
            property_term_id = double('term_id', text: 'openehr')
            property_code = double('code', text: '382')
            
            list_item1 = double('list_item1')
            list_item2 = double('list_item2')
            units1 = double('units1', text: 'kg')
            units2 = double('units2', text: 'g')
            magnitude1 = double('magnitude1')
            magnitude2 = double('magnitude2')
            
            allow(xml).to receive(:at).with('rm_type_name').and_return(rm_type_node)
            allow(xml).to receive(:at).with('occurrences').and_return(occurrences_xml)
            allow(xml).to receive(:at).with('property').and_return(property_xml)
            allow(property_xml).to receive(:at).with('terminology_id/value').and_return(property_term_id)
            allow(property_xml).to receive(:at).with('code_string').and_return(property_code)
            allow(xml).to receive(:xpath).with('.//list').and_return([list_item1, list_item2])
            
            allow(list_item1).to receive(:at).with('units').and_return(units1)
            allow(list_item1).to receive(:at).with('magnitude').and_return(magnitude1)
            allow(list_item1).to receive(:at).with('precision').and_return(nil)
            
            allow(list_item2).to receive(:at).with('units').and_return(units2)
            allow(list_item2).to receive(:at).with('magnitude').and_return(magnitude2)
            allow(list_item2).to receive(:at).with('precision').and_return(nil)
            
            allow(parser).to receive(:occurrences).and_return(double('interval'))

            result = parser.send(:c_dv_quantity, xml, node)
            expect(result).to be_a(OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvQuantity)
            expect(result.rm_type_name).to eq('DV_QUANTITY')
            expect(result.list.size).to eq(2)
          end
        end

        context 'c_code_phrase edge cases' do
          it 'should handle empty code_list' do
            xml = double('xml')
            node = Node.new
            
            term_id_node = double('term_id', text: 'local')
            occurrences_xml = double('occurrences')
            empty_code_node = double('code', text: '')
            
            allow(xml).to receive(:at).with('terminology_id/value').and_return(term_id_node)
            allow(xml).to receive(:at).with('occurrences').and_return(occurrences_xml)
            allow(xml).to receive(:xpath).with('code_list').and_return([empty_code_node])
            allow(parser).to receive(:occurrences).with(occurrences_xml).and_return(double('interval'))

            result = parser.send(:c_code_phrase, xml, node)
            expect(result).to be_a(OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodePhrase)
            expect(result.code_list).to eq([''])
          end

          it 'should handle multiple code_list items' do
            xml = double('xml')
            node = Node.new
            
            term_id_node = double('term_id', text: 'local')
            occurrences_xml = double('occurrences')
            code1 = double('code1', text: 'at0001')
            code2 = double('code2', text: 'at0002')
            
            allow(xml).to receive(:at).with('terminology_id/value').and_return(term_id_node)
            allow(xml).to receive(:at).with('occurrences').and_return(occurrences_xml)
            allow(xml).to receive(:xpath).with('code_list').and_return([code1, code2])
            allow(parser).to receive(:occurrences).with(occurrences_xml).and_return(double('interval'))

            result = parser.send(:c_code_phrase, xml, node)
            expect(result).to be_a(OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodePhrase)
            expect(result.code_list).to eq(['at0001', 'at0002'])
          end

          it 'should handle missing terminology_id' do
            xml = double('xml')
            node = Node.new
            
            occurrences_xml = double('occurrences')
            code_node = double('code', text: 'at0001')
            
            allow(xml).to receive(:at).with('terminology_id/value').and_return(nil)
            allow(xml).to receive(:at).with('occurrences').and_return(occurrences_xml)
            allow(xml).to receive(:xpath).with('code_list').and_return([code_node])
            allow(parser).to receive(:occurrences).with(occurrences_xml).and_return(double('interval'))

            result = parser.send(:c_code_phrase, xml, node)
            expect(result).to be_a(OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodePhrase)
            expect(result.terminology_id).to be_nil
            expect(result.code_list).to eq(['at0001'])
          end
        end
      end
    end
  end
end