require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe AccessGroupRef do
  before(:each) do
    objectid = ObjectID.new(:value => 'deadbeefbabe')
    @access_group_ref = AccessGroupRef.new(:id => objectid,
                                           :type => 'ACCESS_GROUP',
                                           :namespace => 'unknown')
  end

  it 'should be an instance of AccessGroupRef' do
    expect(@access_group_ref).to be_an_instance_of AccessGroupRef
  end

  it 'type should be equal ACCESS_GROUP' do
    expect(@access_group_ref.type).to eq('ACCESS_GROUP')
  end
end
