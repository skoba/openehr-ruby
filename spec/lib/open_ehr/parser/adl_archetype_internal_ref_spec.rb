require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::Parser
include OpenEHR::AM::Archetype

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

    context 'attribute 2 node' do
      before(:all) do
p @archetype.node
        @node = @archetype.node['/attribute2']        
      end

      it 'node  '
    end
  end
end
