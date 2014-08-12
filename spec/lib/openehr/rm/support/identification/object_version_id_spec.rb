require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe ObjectVersionID do
  before(:each) do
    @object_version_id = ObjectVersionID.new(:value => 'F7C5C7B7-75DB-4b39-9A1E-C0BA9BFDBDEC::87284370-2D4B-4e3d-A3F3-F303D2F4F34B::2')
  end

  it 'should be an instance of ObjectVersionID' do
    expect(@object_version_id).to be_an_instance_of ObjectVersionID
  end

  it 'value should be F7C5C7B7-75DB-4b39-9A1E-C0BA9BFDBDEC::87284370-2D4B-4e3d-A3F3-F303D2F4F34B::2' do
    expect(@object_version_id.value).to eq('F7C5C7B7-75DB-4b39-9A1E-C0BA9BFDBDEC::87284370-2D4B-4e3d-A3F3-F303D2F4F34B::2')
  end

  it 'should not be branched' do
    expect(@object_version_id.is_branch?).to be_falsey
  end

  it 'should have valid objectid' do
    expect(@object_version_id.objectid.value).to eq(
      'F7C5C7B7-75DB-4b39-9A1E-C0BA9BFDBDEC'
    )
  end

  it 'should have valid creating_system_id' do
    expect(@object_version_id.creating_system_id.value).to eq(
      '87284370-2D4B-4e3d-A3F3-F303D2F4F34B'
    )
  end

  it 'should raise ArgumentError with invalid format' do
    expect {
      @object_version_id.value = 'invalid:form'
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil object id' do
    expect {
      @object_version_id.objectid = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil creating system id' do
    expect {
      @object_version_id.creating_system_id = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil version_tree_id' do
    expect {
      @object_version_id.version_tree_id = nil
    }.to raise_error ArgumentError
  end

  it 'should be branch if version_identifier represent branch' do
    @object_version_id.version_tree_id.value = '2.3.4'
    expect(@object_version_id.is_branch?).to be_truthy
  end
end
