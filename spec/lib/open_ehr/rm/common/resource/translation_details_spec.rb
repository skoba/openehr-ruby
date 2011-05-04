require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Resource
include OpenEHR::RM::DataTypes::Text

describe TranslationDetails do
  before(:each) do
    language = stub(CodePhrase, :code_string => 'ja')
    author = Hash['Shinji KOBAYASHI', 'Ehime University']
    @translation_details =
      TranslationDetails.new(:language => language,
                             :author => author,
                             :accreditation => 'skoba@moss.gr.jp',
                             :other_details => {'ja' => 'Japanese'})
  end

  it 'should be an instance of TranslationDetails' do
    @translation_details.should be_an_instance_of TranslationDetails
  end

  it 'language should be ja' do
    @translation_details.language.code_string.should == 'ja'
  end

  it 'authour should be Shinji KOBAYASHI' do
    @translation_details.author.keys[0].should == 'Shinji KOBAYASHI'
  end

  it 'accreditation should be skoba@moss.gr.jp' do
    @translation_details.accreditation.should == 'skoba@moss.gr.jp'
  end

  it 'other_details should ja, Japanese' do
    @translation_details.other_details.values[0].should == 'Japanese'
  end
end
