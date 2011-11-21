require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel

describe ADLParser do
  context 'test with slash in comment after use node' do
    before(:all) do
      @archetype = adl14_archetype('adl-test-entry.archetype_internal_ref2.test.adl')
    end

    it 'is an instance of Archetype' do
      @archetype.should be_an_instance_of Archetype
    end

    context 'attribute2' do
      before(:all) do
        @attribute2 = @archetype.definition.attributes[1].children[0]
      end

      it 'is ArchetypeInternalRef' do
        @attribute2.should be_an_instance_of ArchetypeInternalRef
      end

      it 's occurrences upper 2' do
        @attribute2.occurrences.upper.should be 2
      end

      it 's occurrences lower 1' do
        @attribute2.occurrences.lower.should be 1
      end

      it 's path is /attribute2' do
        @attribute2.path.should == '/attribute2'
      end

      it 's target_path is /attribute1' do
        @attribute2.target_path.should == '/attribute1'
      end
    end
  end
end
