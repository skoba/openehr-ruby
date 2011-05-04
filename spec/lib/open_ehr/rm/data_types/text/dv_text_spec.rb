require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification

describe DvText do
  before(:each) do
    terminology_id = TerminologyID.new(:value => 'openehr')
    language = CodePhrase.new(:terminology_id => terminology_id,
                              :code_string => 'ja')
    encoding = CodePhrase.new(:terminology_id => terminology_id,
                              :code_string => 'utf-8')
    @dv_text = DvText.new(:value => 'test',
                          :formatting => 'font = 12pt',
                          :language => language,
                          :encoding => encoding)
  end

  it 'should be an instance of DvText' do
    @dv_text.should be_an_instance_of DvText
  end

  it 's value should be test' do
    @dv_text.value.should == 'test'
  end

  it 'should raise ArgumentError, when value include \n' do
    lambda {
      @dv_text.value = "not valid value\n"
    }.should raise_error(ArgumentError)
  end

  it 'should raise ArgumentError, when value is nil' do
    lambda {
      @dv_text.value = nil
    }.should raise_error(ArgumentError)
  end

  it 'formatting should be font' do
    @dv_text.formatting.should == 'font = 12pt'
  end

  it 'should raise ArgumentError, when formatting is empty' do
    lambda{@dv_text.formatting = ""}.should raise_error(ArgumentError)
  end

  it 'should be mapping list'

  it 'should be hyperlink'

  it 's language code_string should be ja' do
    @dv_text.language.code_string.should == 'ja'
  end

  it 's encoding should be utf-8' do
    @dv_text.encoding.code_string.should == 'utf-8'
  end
end
