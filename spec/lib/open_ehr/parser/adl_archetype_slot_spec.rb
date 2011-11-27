require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::Assertion

# ticket 166

describe ADLParser do
  context ArchetypeSlot do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.archetype_slot.test.adl')
      @slot = archetype.definition.attributes[0].children[0]
    end

    it 'is an isntance of ArchetypeSlot' do
      @slot.should be_an_instance_of ArchetypeSlot
    end

    it 's rm_type name is SECTION' do
      @slot.rm_type_name.should == 'SECTION'
    end

    it 's node_id is at0000' do
      @slot.node_id.should == 'at0001'
    end

    it 's occurrences upper is 1' do
      @slot.occurrences.upper.should be 1
    end

    it 's occurrences lower is 0' do
      @slot.occurrences.lower.should be 0
    end

    context 'include' do
      before(:all) do
        @includes = @slot.includes
      end
      it 's includes 1 constraint' do
        @includes.size.should be 1
      end

      context 'assert expression node' do
        before(:all) do
          @item = @includes[0].expression
        end

        it 'item is an instance of ExpressionBinaryOperator' do
          @item.should be_an_instance_of ExprBinaryOperator
        end
      end
    end


    it 's excludes 2 cnstraints' do
      @slot.excludes.size.should be 2
    end

    
  end
end
