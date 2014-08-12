require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe TerminologyID do
  before(:each) do
    @terminology_id = TerminologyID.new(:value => 'ICD10(2003)')
  end

  it 'should be an instance of TerminologyID' do
    expect(@terminology_id).to be_an_instance_of TerminologyID
  end

  it 's name should be ICD10' do
    expect(@terminology_id.name).to eq('ICD10')
  end

  it 's version_id should be 2003' do
    expect(@terminology_id.version_id).to eq('2003')
  end

  it 's value should be ICD10(2003)' do
    expect(@terminology_id.value).to eq('ICD10(2003)')
  end

  it 'should only name when version_id is nil' do
    @terminology_id.version_id = ''
    expect(@terminology_id.value).to eq('ICD10')
  end

  it 'should has another constructor' do
    @terminology_id = TerminologyID.new(:name => 'SNOMED-CT')
  end
end
