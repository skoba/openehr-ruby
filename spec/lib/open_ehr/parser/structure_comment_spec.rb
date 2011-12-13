# ticket 187
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Structure spec' do
    before(:all) do
      archetype = adl14_archetype('openEHR-EHR-CLUSTER.auscultation.v1.adl')
      @definition = archetype.definition
    end

    it 'rm type name is CLUSTER' do
      @definition.rm_type_name.should == 'CLUSTER'
    end

    it '1st attribute type name is items' do
      @definition.attributes[0].rm_attribute_name.should ==
        'items'
    end
  end
end
