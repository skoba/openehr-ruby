require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Resource
include OpenEHR::RM::DataTypes::Text

describe TranslationDetails do
  before(:each) do
    language = double(CodePhrase, :code_string => 'ja')
    author = Hash['name', 'Shinji KOBAYASHI']
    @translation_details =
      TranslationDetails.new(:language => language,
                             :author => author,
                             :accreditation => 'Japanese Medical license 333',
                             :other_details => {'ja' => 'Japanese'})
  end

  it 'should be an instance of TranslationDetails' do
    expect(@translation_details).to be_an_instance_of TranslationDetails
  end

  it 'language should be ja' do
    expect(@translation_details.language.code_string).to eq('ja')
  end

  it 'authour should be Shinji KOBAYASHI' do
    expect(@translation_details.author['name']).to eq('Shinji KOBAYASHI')
  end

  it 'accreditation should be skoba@moss.gr.jp' do
    expect(@translation_details.accreditation).to eq('Japanese Medical license 333')
  end

  it 'other_details should ja, Japanese' do
    expect(@translation_details.other_details.values[0]).to eq('Japanese')
  end
end
