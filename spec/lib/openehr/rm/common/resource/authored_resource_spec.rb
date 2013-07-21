require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Resource
include OpenEHR::RM::Common::ChangeControl
include OpenEHR::RM::DataTypes::Text

describe AuthoredResource do
  before(:each) do
    original_language = double(CodePhrase, :code_string => 'ja')
    translation_language = double(CodePhrase, :code_string => 'en')
    translation_details = double(TranslationDetails,
                               :language => translation_language)
    translations = Hash['en', translation_details]
    description = double(ResourceDescription, :lifecycle_state => 'initial')
    revision_history = double(RevisionHistory, :most_recent_version => '0.0.3')
#    languages_available = Set.new %w(ja en)
    @authored_resource = AuthoredResource.new(
                  :original_language => original_language,
                  :translations => translations,
                  :description => description,
                  :revision_history => revision_history)
  end

  it 'should be an instance of AuthoredResource' do
    @authored_resource.should be_an_instance_of AuthoredResource
  end

  it 'original language should be ja' do
    @authored_resource.original_language.code_string.should == 'ja'
  end

  it 'translations hash en returns en detail' do
    @authored_resource.translations['en'].language.code_string.should == 'en'
  end

  it 'description lifecycle_state should e initial' do
    @authored_resource.description.lifecycle_state.should == 'initial'
  end

  it 'language_available should be Set(%(ja en))' do
    languages_set = Set.new ['ja', 'en']
    @authored_resource.languages_available.should == languages_set
  end

  it 'current_revision should be 0.0.3' do
    @authored_resource.current_revision.should == '0.0.3'
  end

  it 'should be controlled' do
    @authored_resource.is_controlled?.should be_true
  end

  it 'should not be controlled' do
    @authored_resource.revision_history = nil
    @authored_resource.is_controlled?.should be_false
  end

  it 'should raise ArgumentError with empty translations' do
    expect {
      @authored_resource.translations = Array.new
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when original language is nil' do
    expect {
      @authored_resource.original_language = nil
    }.to raise_error ArgumentError
  end
end
