require File.dirname(__FILE__) + '/../../../../../../spec_helper'

describe OpenEHR::RM::Composition::Content::Entry::Entry do

  let(:name) {OpenEHR::RM::DataTypes::Text::DvText.new(:value => 'entry package')}
  let(:language) { double('language',:code_string => 'ja')}
  let(:encoding) { double('encoding', :code_string => 'UTF-8')}
  let(:subject) { double('PartyProxy')}

  before(:each) do
    external_ref = stub(OpenEHR::RM::Support::Identification::PartyRef, :type => 'entry')
    subject = OpenEHR::RM::Common::Generic::PartyProxy.new(:external_ref => external_ref)
    provider_external_ref = stub(OpenEHR::RM::Support::Identification::PartyRef, :type => 'provider')
    provider = OpenEHR::RM::Common::Generic::PartyProxy.new(:external_ref => provider_external_ref)
    other_participations = stub(Array, :size => 3, :empty? => false)
    workflow_id = stub(OpenEHR::RM::Support::Identification::ObjectRef, :type => 'workflow')
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
    @entry.should be_an_instance_of OpenEHR::RM::Composition::Content::Entry::Entry
  end

  it 'language should be assigned properly' do
    @entry.language.code_string.should == 'ja'
  end

  it 'should raise ArgumentError when nil assign to language' do
    lambda {
      @entry.language = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with invalid language code' do
    terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(:value => 'ISO639-1')
    invalid_language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(:code_string => 'jj',
                                      :terminology_id => terminology_id)
    expect {@entry.language = invalid_language}.to raise_error ArgumentError
  end

  it 'encoding should be assigned properly' do
    @entry.encoding.code_string.should == 'UTF-8'
  end

  it 'should raise ArgumentError when nil assign to encoding' do
    lambda {
      @entry.encoding = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with invalid encoding' do
    terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(:value => 'ISO639-1')
    invalid_encoding = OpenEHR::RM::DataTypes::Text::CodePhrase.new(:terminology_id => terminology_id,
                                      :code_string => 'inv-19')
    expect {@entry.encoding = invalid_encoding}.to raise_error ArgumentError
  end

  it 'subject should be assigned properly' do
    @entry.subject.external_ref.type.should == 'entry'
  end

  it 'should raise ArgumentError when nil assigned to subject' do
    lambda {
      @entry.subject = nil
    }.should raise_error ArgumentError
  end

  it 'provider should be assigned properly' do
    @entry.provider.external_ref.type.should == 'provider'
  end

  it 'other_participations should be assigned properly' do
    @entry.other_participations.size.should be_equal 3
  end

  it 'workflow_id should assigned properly' do
    @entry.workflow_id.type.should == 'workflow'
  end

  it 'subject_is_self? should be determined by subject class' do
    @entry.subject_is_self?.should be_false
  end

  it 'subject_is_self? should be true when subject is instance of PartySelf' do
    @entry.subject = OpenEHR::RM::Common::Generic::PartySelf.new
    @entry.subject_is_self?.should be_true
  end
end
