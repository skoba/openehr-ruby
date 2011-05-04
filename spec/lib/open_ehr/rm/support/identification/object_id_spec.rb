require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe ObjectID do
  before(:each) do
    @object_id = ObjectID.new(:value => '1')
  end

  it 'should be an instance of ObjectID' do
    @object_id.should be_an_instance_of ObjectID
  end

  it 'value should be 1' do
    @object_id.value.should == '1'
  end

  it 'should equal with same value' do
    @object_id.should == ObjectID.new(:value => '1')
  end

  it 'should_not equal with other value' do
    @object_id.should_not == ObjectID.new(:value => 'a')
  end
end
