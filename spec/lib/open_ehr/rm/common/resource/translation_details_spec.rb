require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Resource
include OpenEHR::RM::DataTypes::Text

describe TranslationDetails do
  before(:each) do
    language = stub(CodePhrase, :code_string => 'ja')
    author = Hash['name', 'Shinji KOBAYASHI']
    @translation_details =
      TranslationDetails.new(:language => language,
                             :author => author,
                             :accreditation => 'Japanese Medical license 333',
                             :other_details => {'ja' => 'Japanese'})
  end

  it 'should be an instance of TranslationDetails' do
    @translation_details.should be_an_instance_of TranslationDetails
  end

  it 'language should be ja' do
    @translation_details.language.code_string.should == 'ja'
  end

  it 'authour should be Shinji KOBAYASHI' do
    @translation_details.author['name'].should == 'Shinji KOBAYASHI'
  end

  it 'accreditation should be skoba@moss.gr.jp' do
    @translation_details.accreditation.should == 'Japanese Medical license 333'
  end

  it 'other_details should ja, Japanese' do
    @translation_details.other_details.values[0].should == 'Japanese'
  end
end
