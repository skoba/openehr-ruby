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
    expect(@locatable_ref).to be_an_instance_of LocatableRef
  end

  it 'id should be deadbeef::babe::1' do
    expect(@locatable_ref.id.value).to eq('deadbeef::babe::1')
  end

  it 'path should be test/support' do
    expect(@locatable_ref.path).to eq('test/support')
  end

  it 'as_uri should be ehr://deadbeef::babe::1/test/support' do
    expect(@locatable_ref.as_uri).to eq('ehr://deadbeef::babe::1/test/support')
  end

  it 'should raise ArgumentError with empty path' do
    expect {
      @locatable_ref.path = ''
    }.to raise_error ArgumentError
  end

  it 'should allow a nil path (path is optional per spec)' do
    object_version_id = ObjectVersionID.new(:value => 'deadbeef::babe::1')
    expect {
      LocatableRef.new(:id => object_version_id, :namespace => 'local', :type => 'PERSON')
    }.not_to raise_error
  end

  it 'as_uri should omit the path segment when path is nil' do
    object_version_id = ObjectVersionID.new(:value => 'deadbeef::babe::1')
    locatable_ref = LocatableRef.new(:id => object_version_id, :namespace => 'local', :type => 'PERSON')
    expect(locatable_ref.as_uri).to eq('ehr://deadbeef::babe::1')
  end
end
