require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe AccessGroupRef do
  before(:each) do
    object_id = ObjectID.new(:value => 'deadbeefbabe')
    @access_group_ref = AccessGroupRef.new(:id => object_id,
                                           :type => 'ACCESS_GROUP',
                                           :namespace => 'unknown')
  end

  it 'should be an instance of AccessGroupRef' do
    @access_group_ref.should be_an_instance_of AccessGroupRef
  end

  it 'type should be equal ACCESS_GROUP' do
    @access_group_ref.type.should == 'ACCESS_GROUP'
  end
end
