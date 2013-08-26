# ticket 189
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Unicode binary order marc support spec' do
    before(:all) do
      @archetype = adl14_archetype('adl-test-entry.unicode_BOM_support.test.adl')
    end

    it 'is an instance of Archetype' do
      @archetype.should be_an_instance_of OpenEHR::AM::Archetype::Archetype
    end
  end
end

    
