require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe LocatableRef do
  before(:each) do
    object_version_id = ObjectVersionID.new(:value => 'deadbeef::babe::1')
    @locatable_ref = LocatableRef.new(:id => object_version_id,
                                      :namespace => 'local',
                                      :type =>'PERSON',
                                      :path => 'test/support')
  end

  it 'should be an instance of LocatableRef' do
    @locatable_ref.should be_an_instance_of LocatableRef
  end

  it 'id should be deadbeef::babe::1' do
    @locatable_ref.id.value.should == 'deadbeef::babe::1'
  end

  it 'path should be test/support' do
    @locatable_ref.path.should == 'test/support'
  end

  it 'as_uri should be ehr://deadbeef::babe::1/test/support' do
    @locatable_ref.as_uri.should == 'ehr://deadbeef::babe::1/test/support'
  end

  it 'should raise ArgumentError with empty path' do
    lambda {
      @locatable_ref.path = ''
    }.should raise_error ArgumentError
  end
end
