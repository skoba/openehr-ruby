require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification
#require 'open_ehr/am/openehr_profile/data_types' #/text'
include OpenEHR::AM::OpenEHRProfile::DataTypes::Text

describe CCodePhrase do
  before(:all) do
    term_id = TerminologyID.new(:value => 'ICD10')
    @c_code_phrase  = OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodePhrase.new(:terminology_id => term_id,
                                 :code_list => ['C92', 'C93'])
  end

  it 'is an instance of CCodePhrase' do
    @c_code_phrase.should be_an_instance_of OpenEHR::AM::OpenEHRProfile::DataTypes::Text::CCodePhrase
  end
#  it 'ter
end
