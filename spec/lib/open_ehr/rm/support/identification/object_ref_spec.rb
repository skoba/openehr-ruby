require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe ObjectRef do
  before(:each) do
    object_id = ObjectID.new(:value => 'deadbeefbabe')
    @object_ref = ObjectRef.new(:id => object_id,
                                :namespace => 'local',
                                :type => 'PARTY')
  end

  it 'id.value should deadbeefbabe' do
    @object_ref.id.value.should == 'deadbeefbabe'
  end

  it 'should be an isntance of ObjectRef' do
    @object_ref.should be_an_instance_of ObjectRef
  end

  it 'namespace should be local' do
    @object_ref.namespace.should == 'local'
  end

  it 'type should be PARTY' do
    @object_ref.type.should == 'PARTY'
  end

  it 'should raise ArgumentError with invalid namespace' do
    lambda {
      @object_ref.namespace = 'a****'
    }.should raise_error ArgumentError
  end
end
