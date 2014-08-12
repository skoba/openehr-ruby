require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::EHR
include OpenEHR::RM::Security
include OpenEHR::RM::DataTypes::Text

describe EHRAccess do
  before(:each) do
    name = DvText.new(:value => 'EHRAccess')
    settings = double(AccessControlSettings)
    @ehr_access = EHRAccess.new(:archetype_node_id => 'at0001',
                                :name => name,
                                :settings => settings,
                                :scheme => 'SSL')
  end

  it 'should be an instance of EHRAccess' do
    expect(@ehr_access).to be_an_instance_of EHRAccess
  end

  it 'settings should be assigned, but Security package is not determined' do
    expect(@ehr_access.settings).not_to be_nil
  end

  it 'schema should be assigned properly' do
    expect(@ehr_access.scheme).to eq('SSL')
  end

  it 'should raise ArgumentError with nil schema' do
    expect {
      @ehr_access.scheme = nil
    }.to raise_error ArgumentError
  end
end
