require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe InternetID do
  before(:each) do
    @internet_id = InternetID.new(:value => 'jp.openehr')
  end

  it 'should be an instance of IsoOID' do
    expect(@internet_id).to be_an_instance_of InternetID
  end

  it 'should raise ArgumentError with a malformed domain name' do
    expect {
      InternetID.new(:value => 'not a domain!')
    }.to raise_error ArgumentError
  end
end
