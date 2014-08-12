require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::URI

describe DvEhrUri do
  before(:each) do
    @dv_ehr_uri = DvEhrUri.new(:value => 'ehr://test/87284370-2D4B-4e3d-A3F3-F303D2F4F34B@2005-08-02T04:30:00')
  end

  it 'should be an instance of EhrUri' do
    expect(@dv_ehr_uri).to be_an_instance_of DvEhrUri
  end

  it 's value should be valid' do
    expect(@dv_ehr_uri.value).to eq( 
      'ehr://test/87284370-2D4B-4e3d-A3F3-F303D2F4F34B@2005-08-02T04:30:00'
    )
  end

  it 's scheme should be ehr' do
    expect(@dv_ehr_uri.scheme).to eq('ehr')
  end
end
