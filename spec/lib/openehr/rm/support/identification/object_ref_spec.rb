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
    expect(@object_ref.id.value).to eq('deadbeefbabe')
  end

  it 'should be an isntance of ObjectRef' do
    expect(@object_ref).to be_an_instance_of ObjectRef
  end

  it 'namespace should be local' do
    expect(@object_ref.namespace).to eq('local')
  end

  it 'type should be PARTY' do
    expect(@object_ref.type).to eq('PARTY')
  end

  it 'should raise ArgumentError with invalid namespace' do
    expect {
      @object_ref.namespace = 'a****'
    }.to raise_error ArgumentError
  end
end
