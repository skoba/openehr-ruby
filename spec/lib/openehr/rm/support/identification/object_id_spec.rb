require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe ObjectID do
  before(:each) do
    @object_id = ObjectID.new(:value => '1')
  end

  it 'should be an instance of ObjectID' do
    expect(@object_id).to be_an_instance_of ObjectID
  end

  it 'value should be 1' do
    expect(@object_id.value).to eq('1')
  end

  it 'should equal with same value' do
    expect(@object_id).to eq(ObjectID.new(:value => '1'))
  end

  it 'should_not equal with other value' do
    expect(@object_id).not_to eq(ObjectID.new(:value => 'a'))
  end
end
