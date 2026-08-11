require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe IsoOID do
  before(:each) do
    @iso_oid = IsoOID.new(:value => '1.3.6.0.1')
  end

  it 'should be an instance of IsoOID' do
    expect(@iso_oid).to be_an_instance_of IsoOID
  end

  it 'should raise ArgumentError with a malformed OID' do
    expect {
      IsoOID.new(:value => 'not.an.oid')
    }.to raise_error ArgumentError
  end
end
