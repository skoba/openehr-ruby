require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Encapsulated
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::URI
include OpenEHR::RM::Support::Identification

describe DvMultimedia do
  before(:each) do
    media_type = double(CodePhrase, :code_string => 'text/xml')
    charset = double(CodePhrase, :code_string => 'UTF-8')
    uri = double(DvUri, :value => 'http://openehr.jp/')
    data = Array['123412', '123112']
    compression_algorithm = double(CodePhrase, :code_string => 'gzip')
    integrity_check = Array['123456789ABCDEF','DEADBEEF']
    integrity_check_algorithm = double(CodePhrase, :code_string => 'SHA-1')
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
    expect(@dv_multimedia).to be_an_instance_of DvMultimedia
  end

  it 's value should be <xml>test</xml>' do
    expect(@dv_multimedia.value).to eq('<xml>test</xml>')
  end

  it 's media_type should be text/xml' do
    expect(@dv_multimedia.media_type.code_string).to eq('text/xml')
  end

  it 's size should be equal 15' do
    expect(@dv_multimedia.size).to be_equal 15
  end

  it 's charset should be UTF-8' do
    expect(@dv_multimedia.charset.code_string).to eq('UTF-8')
  end

  it 's uri value should be http://openehr.jp/ ' do
    expect(@dv_multimedia.uri.value).to eq('http://openehr.jp/')
  end

  it 's data[0] should be 123412' do
    expect(@dv_multimedia.data[0]).to eq('123412')
  end

  it 's compression_algorithm should be gzip' do
    expect(@dv_multimedia.compression_algorithm.code_string).to eq('gzip')
  end

  it 's integrity_check[1] should be DEADBEEF' do
    expect(@dv_multimedia.integrity_check[1]).to eq('DEADBEEF')
  end

  it 's integrity_check_algorithm should be SHA-1' do
    expect(@dv_multimedia.integrity_check_algorithm.code_string).to eq('SHA-1')
  end

  it 's alternate text should be test' do
    expect(@dv_multimedia.alternate_text).to eq('test')
  end

  it 'has_integrity_check should be true'

  it 'is compressed should be true'

  it 'is_external should be true'

  it 'is_internal should be false'
end
