require File.dirname(__FILE__) + '/../../../../../../spec_helper'

describe OpenEHR::RM::Composition::Content::Entry::Entry do

  let(:name) {OpenEHR::RM::DataTypes::Text::DvText.new(:value => 'entry package')}
  let(:language) { double('language',:code_string => 'ja')}
  let(:encoding) { double('encoding', :code_string => 'UTF-8')}
  let(:subject) { double('PartyProxy')}

  before(:each) do
    external_ref = double(OpenEHR::RM::Support::Identification::PartyRef, :type => 'entry')
    subject = OpenEHR::RM::Common::Generic::PartyProxy.new(:external_ref => external_ref)
    provider_external_ref = double(OpenEHR::RM::Support::Identification::PartyRef, :type => 'provider')
    provider = OpenEHR::RM::Common::Generic::PartyProxy.new(:external_ref => provider_external_ref)
    other_participations = double(Array, :size => 3, :empty? => false)
    workflow_id = double(OpenEHR::RM::Support::Identification::ObjectRef, :type => 'workflow')
    @entry = OpenEHR::RM::Composition::Content::Entry::Entry.new(:archetype_node_id => 'at0001',
                       :name => DvText.new(:value => 'entry test'),
                       :language => language,
                       :encoding => encoding,
                       :subject => subject,
                       :provider => provider,
                       :other_participations => other_participations,
                       :workflow_id => workflow_id)
  end

  it 'should be an instance of Entry' do
    expect(@entry).to be_an_instance_of OpenEHR::RM::Composition::Content::Entry::Entry
  end

  it 'language should be assigned properly' do
    expect(@entry.language.code_string).to eq('ja')
  end

  it 'should raise ArgumentError when nil assign to language' do
    expect {
      @entry.language = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with invalid language code' do
    terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(:value => 'ISO639-1')
    invalid_language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(:code_string => 'jj',
                                      :terminology_id => terminology_id)
    expect {@entry.language = invalid_language}.to raise_error ArgumentError
  end

  it 'encoding should be assigned properly' do
    expect(@entry.encoding.code_string).to eq('UTF-8')
  end

  it 'should raise ArgumentError when nil assign to encoding' do
    expect {
      @entry.encoding = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with invalid encoding' do
    terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(:value => 'ISO639-1')
    invalid_encoding = OpenEHR::RM::DataTypes::Text::CodePhrase.new(:terminology_id => terminology_id,
                                      :code_string => 'inv-19')
    expect {@entry.encoding = invalid_encoding}.to raise_error ArgumentError
  end

  it 'subject should be assigned properly' do
    expect(@entry.subject.external_ref.type).to eq('entry')
  end

  it 'should raise ArgumentError when nil assigned to subject' do
    expect {
      @entry.subject = nil
    }.to raise_error ArgumentError
  end

  it 'provider should be assigned properly' do
    expect(@entry.provider.external_ref.type).to eq('provider')
  end

  it 'other_participations should be assigned properly' do
    expect(@entry.other_participations.size).to be_equal 3
  end

  it 'workflow_id should assigned properly' do
    expect(@entry.workflow_id.type).to eq('workflow')
  end

  it 'subject_is_self? should be determined by subject class' do
    expect(@entry.subject_is_self?).to be_falsey
  end

  it 'subject_is_self? should be true when subject is instance of PartySelf' do
    @entry.subject = OpenEHR::RM::Common::Generic::PartySelf.new
    expect(@entry.subject_is_self?).to be_truthy
  end
end
