require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Resource
include OpenEHR::RM::DataTypes::Text

describe ResourceDescriptionItem do
  before(:each) do
    language = double(CodePhrase, :defining_code => 'ja')
    original_resource_uri = {'jp' => 'http://openehr.jp/'}
    @resource_description_item =
      ResourceDescriptionItem.new(:language => language,
                                  :purpose => 'test',
                                  :keywords => ['openehr'],
                                  :use => 'development',
                                  :misuse => 'none',
                                  :copyright => 'Shinji KOBAYASHI',
                                  :original_resource_uri => original_resource_uri,
                                  :other_details => {'charset' => 'UTF-8'})
  end

  it 'should be an instance of ResourceDescriptionItem' do
    @resource_description_item.should be_an_instance_of ResourceDescriptionItem
  end

  it 'language should ja' do
    @resource_description_item.language.defining_code.should == 'ja'
  end

  it 'purpose should be test' do
    @resource_description_item.purpose.should == 'test'
  end

  it 'should raise ArgumentError with nil purpose' do
    expect {
      @resource_description_item.purpose = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty purpose' do
    expect {
      @resource_description_item.purpose = ''
    }.to raise_error ArgumentError
  end

  it 'keywords should [openehr]' do
    @resource_description_item.keywords.should == ['openehr']
  end

  it 'use should be development' do
    @resource_description_item.use.should == 'development'
  end

  it 'should raise ArgumentError with use is empty' do
    expect {
      @resource_description_item.use = ''
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil use' do
    expect {
      @resource_description_item.use = nil
    }.not_to raise_error
  end

  it 'misuse should be none' do
    @resource_description_item.misuse.should == 'none'
  end

  it 'should raise ArgumentError with empty misuse' do
    expect {
      @resource_description_item.misuse = ''
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil misuse' do
    expect {
      @resource_description_item.misuse = nil
    }.not_to raise_error
  end

  it 'copyright should be Shinji KOBAYASHI' do
    @resource_description_item.copyright.should == 'Shinji KOBAYASHI'
  end

  it 'should raise error with empty copyright' do
    expect {
      @resource_description_item.copyright = ''
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil copyright' do
    expect {
      @resource_description_item.copyright = nil
    }.not_to raise_error
  end

  it 'original_resource_uri should {jp, http://openehr.jp/}' do
    @resource_description_item.original_resource_uri.should ==
      {'jp' => 'http://openehr.jp/'}
  end

  it 'other_details should {charset, UTF-8}' do
    @resource_description_item.other_details.should ==
      {'charset' => 'UTF-8'}
  end
end
