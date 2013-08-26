# ticket 186
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Special string' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.special_string.test.adl')
      @attr = archetype.definition.attributes[0].children[0].attributes
    end

    it '1st node string is some\"thing' do
      @attr[0].children[0].list[0].should == 'some\"thing'
    end

    it '2nd node string is any\\thing' do
      @attr[1].children[0].list[0].should == "any\\thing"
    end
  end
end
