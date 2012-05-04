# ticket 187
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Structure spec' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.structure_test2.test.adl')
      @definition = archetype.definition
    end

    it 'rm type name is ENTRY' do
      @definition.rm_type_name.should == 'ENTRY'
    end

    it '1st attribute type name is items' do
      @definition.attributes[0].rm_attribute_name.should ==
        'subject_relationship'
    end
  end
end
