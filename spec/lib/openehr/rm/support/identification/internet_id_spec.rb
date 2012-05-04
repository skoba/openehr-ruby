require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe InternetID do
  before(:each) do
    @internet_id = InternetID.new(:value => 'jp.openehr')
  end

  it 'should be an instance of IsoOID' do
    @internet_id.should be_an_instance_of InternetID
  end
end
