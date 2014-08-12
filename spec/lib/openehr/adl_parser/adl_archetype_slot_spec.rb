require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::AM::Archetype::Assertion

# ticket 166

describe ADLParser do
  context ArchetypeSlot do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.archetype_slot.test.adl')
      @slot = archetype.definition.attributes[0].children[0]
    end

    it 'is an isntance of ArchetypeSlot' do
      expect(@slot).to be_an_instance_of ArchetypeSlot
    end

    it 's rm_type name is SECTION' do
      expect(@slot.rm_type_name).to eq('SECTION')
    end

    it 's node_id is at0000' do
      expect(@slot.node_id).to eq('at0001')
    end

    it 's occurrences upper is 1' do
      expect(@slot.occurrences.upper).to be 1
    end

    it 's occurrences lower is 0' do
      expect(@slot.occurrences.lower).to be 0
    end

    context 'include' do
      before(:all) do
        @includes = @slot.includes
      end
      it 's includes 1 constraint' do
        expect(@includes.size).to be 1
      end

      context 'assert expression node' do
        before(:all) do
          @item = @includes[0].expression
        end

        it 'item is an instance of ExprBinaryOperator' do
          expect(@item).to be_an_instance_of ExprBinaryOperator
        end

        it 'operator is OP_MATCHES' do
          expect(@item.operator).to eq(OperatorKind::OP_MATCHES)
        end
        
        context 'left operand' do
          before(:all) do
            @left_operand = @item.left_operand
          end

          it 'is instance of ExprLeaf' do
            expect(@left_operand).to be_an_instance_of ExprLeaf
          end

          it 's item is domain_concept' do
            expect(@left_operand.item).to eq('domain_concept')
          end
        end

        context 'right operand' do
          before(:all) do
            @right_operand = @item.right_operand
          end

          it 'is an instance of ExprLeaf' do
            expect(@right_operand).to be_an_instance_of ExprLeaf
          end

          it 's item type is CString' do
            expect(@right_operand.item).to be_an_instance_of CString
          end

          it 's item pattern is /blood_pressure.v1/' do
            expect(@right_operand.item.pattern).to eq('/blood_pressure.v1/')
          end
        end
      end
    end

    context 'excludes' do
      before(:all) do
        @excludes = @slot.excludes
      end

      it 's excludes 2 cnstraints' do
        expect(@excludes.size).to be 2
      end

      context '1st node' do
        before(:all) do
          @node = @excludes[0].expression
        end

        it 'is an instance of ExprBinaryOperator' do
          expect(@node).to be_an_instance_of ExprBinaryOperator
        end

        it 's operator is OP_MATCHES' do
          expect(@node.operator).to eq(OperatorKind::OP_MATCHES)
        end

        context 'left operand' do
          before(:all) do
            @left_operand = @node.left_operand
          end

          it 'is an instance of ExprLeaf' do
            expect(@left_operand).to be_an_instance_of ExprLeaf
          end

          it 's item type is domain_concept' do
            expect(@left_operand.item).to eq('domain_concept')
          end
        end

        context 'right operand' do
          before(:all) do
            @right_operand = @node.right_operand
          end

          it 'is an instance of ExprLeaf' do
            expect(@right_operand).to be_an_instance_of ExprLeaf
          end

          it 's item should be an instance of CString' do
            expect(@right_operand.item).to be_an_instance_of CString
          end

          it 's item pattern is /blood_pressure.v2/' do
            expect(@right_operand.item.pattern).to eq('/blood_pressure.v2/')
          end
        end
      end

      context '2nd node' do
        before(:all) do
          @node = @excludes[1].expression
        end

        it 'is an instance of ExprBinaryOperator' do
          expect(@node).to be_an_instance_of ExprBinaryOperator
        end

        it 's operator is OP_MATCHES' do
          expect(@node.operator).to eq(OperatorKind::OP_MATCHES)
        end

        context 'left operand' do
          before(:all) do
            @left_operand = @node.left_operand
          end

          it 'is an instance of ExprLeaf' do
            expect(@left_operand).to be_an_instance_of ExprLeaf
          end

          it 's item is domain_concept' do
            expect(@left_operand.item).to eq('domain_concept')
          end
        end

        context 'right operand' do
          before(:all) do
            @right_operand = @node.right_operand
          end

          it 'is an instance of ExprLeaf' do
            expect(@right_operand).to be_an_instance_of ExprLeaf
          end

          it 's item type is CString' do
            expect(@right_operand.item).to be_an_instance_of CString
          end

          it 's item pattern is /.*/' do
            expect(@right_operand.item.pattern).to eq('/.*/')
          end
        end
      end
    end
  end
end 
