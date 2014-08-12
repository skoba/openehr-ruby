require 'spec_helper' #_relative File.dirname(__FILE__) + '/../../../spec_helper'
require_relative File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel

describe ADLParser do
  context 'test with slash in comment after use node' do
    before(:all) do
      @archetype = adl14_archetype('adl-test-entry.archetype_internal_ref2.test.adl')
    end

    it 'is an instance of Archetype' do
      expect(@archetype).to be_an_instance_of Archetype
    end

    context 'attribute2' do
      before(:all) do
        @attribute2 = @archetype.definition.attributes[1].children[0]
      end

      it 'is ArchetypeInternalRef' do
        expect(@attribute2).to be_an_instance_of ArchetypeInternalRef
      end

      it 's occurrences upper 2' do
        expect(@attribute2.occurrences.upper).to be 2
      end

      it 's occurrences lower 1' do
        expect(@attribute2.occurrences.lower).to be 1
      end

      it 's path is /attribute2' do
        expect(@attribute2.path).to eq('/attribute2')
      end

      it 's target_path is /attribute1' do
        expect(@attribute2.target_path).to eq('/attribute1')
      end
    end
  end
end
