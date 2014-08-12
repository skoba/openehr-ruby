require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Encapsulated
include OpenEHR::RM::DataTypes::Text

describe DvEncapsulated do
  before(:each) do
    dummy = 'test'
    charset = double(CodePhrase, :code_string => 'UTF-8')
    language = double(CodePhrase, :code_string => 'ja')
    @dv_encapsulated = DvEncapsulated.new(:value => dummy,
                                          :charset => charset,
                                          :language => language)
  end

  it 's value should be test' do
    expect(@dv_encapsulated.value).to eq('test')
  end

  it 's size should be 4' do
    expect(@dv_encapsulated.size).to be_equal 4
  end

  it 's charset should be utf-8' do
    expect(@dv_encapsulated.charset.code_string).to eq('UTF-8')
  end

  it 's langage should be ja' do
    expect(@dv_encapsulated.language.code_string).to eq('ja')
  end

  it 'should raise ArgumentError when language is invalid' do
    wrong_lang = double(CodePhrase, :code_string => 'jj')
    expect{@dv_encapsulated.language = wrong_lang}.
      to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError when charset is invalid' do
    wrong_charset = double(CodePhrase, :code_string => 'UBK')
    expect {@dv_encapsulated.charset = wrong_charset}.
      to raise_error(ArgumentError)
  end
end
