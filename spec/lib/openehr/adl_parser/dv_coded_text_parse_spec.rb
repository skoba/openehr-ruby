require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include ::OpenEHR::RM::DataTypes::Text
require 'openehr/am/openehr_profile/data_types/text'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Text

describe ADLParser do
  describe DvCodedText do
    before(:all) do
      archetype = adl14_archetype('adl-test-composition.dv_coded_text.test.adl')
      @c_code_phrase = archetype.definition.attributes[0].children[0].
        attributes[0].children[0]
    end

    it 'is an instance of CCodePhrase' do
      expect(@c_code_phrase).to be_an_instance_of CCodePhrase
    end

    it 'terminology is openehr' do
      expect(@c_code_phrase.terminology_id.value).to eq('openehr')
    end

    it 'code list is 431' do
      expect(@c_code_phrase.code_list).to eq(['431'])
    end
  end
end
