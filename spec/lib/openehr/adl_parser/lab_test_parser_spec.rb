require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'lab_test parser error_check' do
    before(:all) do
      @archetype = adl14_archetype('openEHR-EHR-OBSERVATION.lab_test.v1.adl')
    end

    it 'is an instance of archetype' do
      @archetype.should be_an_instance_of OpenEHR::AM::Archetype::Archetype
    end
  end
end
