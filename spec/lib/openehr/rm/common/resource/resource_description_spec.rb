require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Resource

describe ResourceDescription do
  before(:each) do
    original_author = {'Shinji KOBAYASHI' => 'Ehime University'}
    other_contributors = ['Akimichi TATSUKAWA']
    resource_description_item =
      double(ResourceDescriptionItem, :purpose => 'test')
    details = {'case' => resource_description_item}
    other_details = {'charset' => 'UTF-8'}
    parent_resource = double(AuthoredResource, :current_revision => '0.0.3')
    @resource_description =
      ResourceDescription.new(:original_author => original_author,
                              :other_contributors => other_contributors,
                              :lifecycle_state => 'initial',
                              :details => details,
                              :other_details => other_details,
                              :resource_package_uri => 'http://openehr.jp/',
                              :parent_resource => parent_resource)
  end

  it 'should be an instance of ResourceDescription' do
    @resource_description.should be_an_instance_of ResourceDescription
  end

  it 'original author should be Shinji KOBAYASHI' do
    @resource_description.original_author.keys[0].should ==
      'Shinji KOBAYASHI'
  end

  it 'other_contributors should be Akimichi TATSUKAWA' do
    @resource_description.other_contributors[0].should == 
      'Akimichi TATSUKAWA'
  end

  it 'lifecycle_state should be initial' do
    @resource_description.lifecycle_state.should == 'initial'
  end

  it 'details key should be case' do
    @resource_description.details.keys[0].should == 'case'
  end

  it 'other_details value should be charset, UTF-8' do
    @resource_description.other_details.should == {'charset' => 'UTF-8'}
  end

  it 'resource package uri should be http://openehr.jp/' do
    @resource_description.resource_package_uri.should == 'http://openehr.jp/'
  end

  it 'parent_resource current_revision should be 0.0.3' do
    @resource_description.parent_resource.current_revision.should == '0.0.3'
  end

  it 'should raise ArgumentError with nil original author' do
    expect {
      @resource_description.original_author = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil lifecycle_state' do
    expect {
      @resource_description.lifecycle_state = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil details' do
    expect {
      @resource_description.details = {}
    }.to raise_error ArgumentError
  end
end
