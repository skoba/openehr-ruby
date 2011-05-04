require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe ObjectVersionID do
  before(:each) do
    @object_version_id = ObjectVersionID.new(:value => 'F7C5C7B7-75DB-4b39-9A1E-C0BA9BFDBDEC::87284370-2D4B-4e3d-A3F3-F303D2F4F34B::2')

  end

  it 'should be an instance of ObjectVersionID' do
    @object_version_id.should be_an_instance_of ObjectVersionID
  end

  it 'value should be F7C5C7B7-75DB-4b39-9A1E-C0BA9BFDBDEC::87284370-2D4B-4e3d-A3F3-F303D2F4F34B::2' do
    @object_version_id.value.should == 'F7C5C7B7-75DB-4b39-9A1E-C0BA9BFDBDEC::87284370-2D4B-4e3d-A3F3-F303D2F4F34B::2'
  end

  it 'should not be branched' do
    @object_version_id.is_branch?.should be_false
  end

  it 'should have valid object_id' do
    @object_version_id.object_id.value.should ==
      'F7C5C7B7-75DB-4b39-9A1E-C0BA9BFDBDEC'
  end

  it 'should have valid creating_system_id' do
    @object_version_id.creating_system_id.value.should ==
      '87284370-2D4B-4e3d-A3F3-F303D2F4F34B'
  end

  it 'should raise ArgumentError with invalid format' do
    lambda {
      @object_version_id.value = 'invalid:form'
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil object id' do
    lambda {
      @object_version_id.object_id = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil creating system id' do
    lambda {
      @object_version_id.creating_system_id = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil version_tree_id' do
    lambda {
      @object_version_id.version_tree_id = nil
    }.should raise_error ArgumentError
  end

  it 'should be branch if version_identifier represent branch' do
    @object_version_id.version_tree_id.value = '2.3.4'
    @object_version_id.is_branch?.should be_true
  end
end
