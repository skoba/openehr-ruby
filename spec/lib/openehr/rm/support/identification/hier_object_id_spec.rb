require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe HierObjectID do
  before(:each) do
    @hier_object_id = HierObjectID.new(:value => '2003045')
  end

  it 'should be an instance of HierObjectID' do
    expect(@hier_object_id).to be_an_instance_of HierObjectID
  end
end
