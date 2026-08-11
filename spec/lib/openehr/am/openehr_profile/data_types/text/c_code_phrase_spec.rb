require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include ::OpenEHR::RM::DataTypes::Text
include ::OpenEHR::AssumedLibraryTypes
include ::OpenEHR::RM::Support::Identification
require 'openehr/am/openehr_profile/data_types/text'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Text

describe CCodePhrase do
  before(:all) do
    term_id = TerminologyID.new(:value => 'ICD10')
    occurrences = Interval.new(:upper => 1)
    @c_code_phrase  = CCodePhrase.new(:terminology_id => term_id,
                                      :code_list => ['C92', 'C93'],
                                      :path => 'value/text',
                                      :occurrences => occurrences,
                                      :rm_type_name => 'CodePhrase')
  end

  it 'is an instance of CCodePhrase' do
    expect(@c_code_phrase).to be_an_instance_of CCodePhrase
  end

  it 'terminology_id is ICD10' do
    expect(@c_code_phrase.terminology_id.value).to eq('ICD10')
  end

  it 'code_list is C92, C93' do
    expect(@c_code_phrase.code_list).to eq(['C92', 'C93'])
  end

  it 'occurrences upper is 1' do
    expect(@c_code_phrase.occurrences.upper).to be 1
  end

  describe '#valid_value?' do
    it 'is true for a CODE_PHRASE with a matching terminology and code in the list' do
      value = CodePhrase.new(:terminology_id => TerminologyID.new(:value => 'ICD10'),
                             :code_string => 'C92')
      expect(@c_code_phrase.valid_value?(value)).to be true
    end

    it 'is false when the code is not in the list' do
      value = CodePhrase.new(:terminology_id => TerminologyID.new(:value => 'ICD10'),
                             :code_string => 'Z00')
      expect(@c_code_phrase.valid_value?(value)).to be false
    end

    it 'is false when the terminology differs' do
      value = CodePhrase.new(:terminology_id => TerminologyID.new(:value => 'SNOMED-CT'),
                             :code_string => 'C92')
      expect(@c_code_phrase.valid_value?(value)).to be false
    end

    it 'accepts a bare code string too' do
      expect(@c_code_phrase.valid_value?('C92')).to be true
      expect(@c_code_phrase.valid_value?('Z00')).to be false
    end

    it 'is true for anything when any_allowed' do
      unconstrained = CCodePhrase.new(:path => 'value/text', :occurrences => Interval.new(:upper => 1),
                                      :rm_type_name => 'CodePhrase')
      expect(unconstrained.valid_value?('anything')).to be true
    end
  end
end
