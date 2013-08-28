# ticket 182
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Mixed node types' do
    before(:all) do
      @archetype = adl14_archetype('adl-test-entry.mixed_node_types.draft.adl')
    end

    it 'is an instance of Archetype' do
      @archetype.should be_an_instance_of OpenEHR::AM::Archetype::Archetype
    end
  end
end

