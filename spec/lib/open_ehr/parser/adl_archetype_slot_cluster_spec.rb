require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::AM::Archetype::Assertion

# ticket 166

describe ADLParser do
  context ArchetypeSlot do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.archetype_slot.test2.adl')
      @slot = archetype.definition.attributes[0].children[0]
    end

    it 'is an instance of ArchetypeSlot' do
      @slot.should be_an_instance_of ArchetypeSlot
    end

    it 's node id is at0001' do
      @slot.node_id.should == 'at0001'
    end

    it 's occurrences upper is 1' do
      @slot.occurrences.upper.should be 1
    end

    it 's occurrences lower is 0' do
      @slot.occurrences.lower.should be 0
    end

    it 's rm type name is SECTION' do
      @slot.rm_type_name.should == 'SECTION'
    end

    it 's path is /content[at0001]' do
      @slot.path.should == '/content[at0001]'
    end

    context 'includes' do
      before(:all) do
        @includes = @slot.includes
      end

      it 's size is 1' do
        @includes.size.should be 1
      end

      it 's string_expression is archetype_id/value matches {/openEHR-EHR-CLUSTER\.device\.v1/}' do
        @includes[0].string_expression.should ==
          'archetype_id/value matches {/openEHR-EHR-CLUSTER\.device\.v1/}'
      end

      context 'item' do
        before(:all) do
          @item = @includes[0].expression
        end

        it 'is an instance of ExprBooleanExpression' do
          @item.should be_an_instance_of ExprBinaryOperator
        end

        it 's operator is OP_MATCHES' do
          @item.operator.should == OperatorKind::OP_MATCHES
        end

        context 'left operand' do
          before(:all) do
            @left_operand = @item.left_operand
          end

          it 'is an instance of ExprLeaf' do
            @left_operand.should be_an_instance_of ExprLeaf
          end

          it 's item is archetype_id/value' do
            @left_operand.item.should == 'archetype_id/value'
          end
        end

        context 'right operand' do
          before(:all) do
            @right_operand = @item.right_operand
          end

          it 'is an intance of ExprLeaf' do
            @right_operand.should be_an_instance_of ExprLeaf
          end

          it 's item type is CString' do
            @right_operand.item.should be_an_instance_of CString
          end

          it 's item pattern is /openEHR-EHR-CLUSTER\.device\.v1/' do
            @right_operand.item.pattern.should == '/openEHR-EHR-CLUSTER\.device\.v1/'
          end
        end
      end
    end
  end
end
