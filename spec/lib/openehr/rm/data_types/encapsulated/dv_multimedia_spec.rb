require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Encapsulated
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::URI
include OpenEHR::RM::Support::Identification

describe DvMultimedia do
  before(:each) do
    media_type = stub(CodePhrase, :code_string => 'text/xml')
    charset = stub(CodePhrase, :code_string => 'UTF-8')
    uri = stub(DvUri, :value => 'http://openehr.jp/')
    data = Array['123412', '123112']
    compression_algorithm = stub(CodePhrase, :code_string => 'gzip')
    integrity_check = Array['123456789ABCDEF','DEADBEEF']
    integrity_check_algorithm = stub(CodePhrase, :code_string => 'SHA-1')
    alternate_text = 'test'
    @dv_multimedia = DvMultimedia.new(:value => '<xml>test</xml>',
                                      :media_type => media_type,
                                      :charset => charset,
                                      :uri => uri,
                                      :data => data,
                                      :compression_algorithm => compression_algorithm,
                                      :integrity_check => integrity_check,
                                      :integrity_check_algorithm => integrity_check_algorithm,
                                      :alternate_text => alternate_text)
  end

  it 'should be an instance of DvMultimedia' do
    @dv_multimedia.should be_an_instance_of DvMultimedia
  end

  it 's value should be <xml>test</xml>' do
    @dv_multimedia.value.should == '<xml>test</xml>'
  end

  it 's media_type should be text/xml' do
    @dv_multimedia.media_type.code_string.should == 'text/xml'
  end

  it 's size should be equal 15' do
    @dv_multimedia.size.should be_equal 15
  end

  it 's charset should be UTF-8' do
    @dv_multimedia.charset.code_string.should == 'UTF-8'
  end

  it 's uri value should be http://openehr.jp/ ' do
    @dv_multimedia.uri.value.should == 'http://openehr.jp/'
  end

  it 's data[0] should be 123412' do
    @dv_multimedia.data[0].should == '123412'
  end

  it 's compression_algorithm should be gzip' do
    @dv_multimedia.compression_algorithm.code_string.should == 'gzip'
  end

  it 's integrity_check[1] should be DEADBEEF' do
    @dv_multimedia.integrity_check[1].should == 'DEADBEEF'
  end

  it 's integrity_check_algorithm should be SHA-1' do
    @dv_multimedia.integrity_check_algorithm.code_string.should == 'SHA-1'
  end

  it 's alternate text should be test' do
    @dv_multimedia.alternate_text.should == 'test'
  end

  it 'has_integrity_check should be true'

  it 'is compressed should be true'

  it 'is_external should be true'

  it 'is_internal should be false'
end
