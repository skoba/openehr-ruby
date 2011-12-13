# ticket 183
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Mixed node types' do
    before(:all) do
      @archetype = adl14_archetype('adl-test-entry.most_minimal.test.adl')
    end

    it 'is an instance of Archetype' do
      @archetype.should be_an_instance_of OpenEHR::AM::Archetype::Archetype
    end

    it 'original language is en' do
      @archetype.original_language.code_string.should == 'en'
    end
  end
end
