require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include ::OpenEHR::RM::DataTypes::Text
require 'open_ehr/am/openehr_profile/data_types/text'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Text

describe ADLParser do
  describe DvCodedText do
    before(:all) do
      archetype = adl14_archetype('adl-test-composition.dv_coded_text.test.adl')
      @c_code_phrase = archetype.definition.attributes[0].children[0].
        attributes[0].children[0]
    end

    it 'is an instance of CCodePhrase' do
      @c_code_phrase.should be_an_instance_of CCodePhrase
    end

    it 'terminology is openehr' do
      @c_code_phrase.terminology_id.value.should == 'openehr'
    end

    it 'code list is 431' do
      @c_code_phrase.code_list.should == ['431']
    end
  end
end
