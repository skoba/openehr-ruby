require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::Parser
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel

describe ADLParser do
  context 'ArchetypeInternalRef behavior test' do
    before(:all) do
      target_adl_file = 'adl-test-entry.archetype_internal_ref.test.adl'
      ap = ADLParser.new(ADL14DIR + target_adl_file)
      @archetype = ap.parse
    end

    it 'Archetype instance is generated' do
      @archetype.should be_instance_of Archetype
    end

    context 'attribute 1 node' do
      before(:all) do
        @node = @archetype.definition.attributes[0]
      end

      it 's path is attribute 1' do
        @node.path.should == '/attribute1'
      end

      it 's rm attribute name is SECTION' do
        @node.rm_attribute_name.should == 'attribute1'
      end

      context 'children' do
        before(:all) do
          @child = @node.children[0]
        end

        it 's rm type name is SECTION' do
          @child.rm_type_name.should == 'SECTION'
        end
      end
    end

    context 'attrubute 2 node' do
      before(:all) do
        @node = @archetype.definition.attributes[1]
      end

      it 's path is attribute 2' do
        @node.path.should == '/attribute2'
      end

      context 'child' do
        before(:all) do
          @child = @node.children[0]
        end

        it 'is instance of ArchetypeInternalRef' do
          @child.should be_an_instance_of ArchetypeInternalRef
        end

        it 's target path is /attribute1' do
          @child.target_path.should == '/attribute1'
        end

        it 'path is /attribute2' do
          @child.path.should == '/attribute2'
        end

        it 's occurrences upper is 2' do
          @child.occurrences.upper.should be 2
        end

        it 's occurrences lower is 1' do
          @child.occurrences.lower.should be 1
        end
      end

      context 'attribute 3 node' do
        before(:all) do
          @node = @archetype.definition.attributes[2]
        end

        it 's path is /attribute3' do
          @node.path.should == '/attribute3'
        end

        context 'child1' do
          before(:all) do
            @child1 = @node.children[0]
          end

          it 's path is /attribute3' do
            @child1.path.should == '/attribute3'
          end

          it 's target path is /items[at0001]' do
            @child1.target_path.should == '/items[at0001]'
          end

          it 's rm type name is COMPLEX_OBJECT' do
            @child1.rm_type_name.should == 'COMPLEX_OBJECT'
          end
        end

        context 'child2' do
          before(:all) do
            @child2 = @node.children[1]
          end

          it 's path is /attribute3' do
            @child2.path.should == '/attribute3'
          end

          it 's target path is /items[at0002]' do
            @child2.target_path.should == '/items[at0002]'
          end

          it 's rm_type_name is COMPLEX_OBJECT' do
            @child2.rm_type_name.should == 'COMPLEX_OBJECT'
          end
        end
      end
    end
  end
end
