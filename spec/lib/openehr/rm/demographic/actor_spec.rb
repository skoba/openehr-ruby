require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification

describe Actor do
  before(:each) do
    name = DvText.new(:value => 'actor')
    uid = HierObjectID.new(:value => '01')
    identities = double(Set, :empty? => false)
    roles = double(Set, :size => 2, :empty? => false)
    languages = double(Array, :size => 3, :empty? => false)
    @actor = Actor.new(:archetype_node_id => 'at0000',
                       :name => name,
                       :uid => uid,
                       :identities => identities,
                       :roles => roles,
                       :languages => languages)
  end

  it 'should be an instance of Actor' do
    @actor.should be_an_instance_of Actor
  end

  it 'roles should be assigned properly' do
    @actor.roles.size.should be_equal 2
  end

  it 'should raise ArgumentError with empty roles' do
    expect {
      @actor.roles = Set.new
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil roles' do
    expect {
      @actor.roles = nil
    }.not_to raise_error
  end

  it 'languages should be assigned properly' do
    @actor.languages.size.should be_equal 3
  end

  it 'should raise ArgumentError with empty languages' do
    expect {
      @actor.languages = Set.new
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil languages' do
    expect {
      @actor.languages = nil
    }.not_to raise_error
  end

  describe 'has_legal_identity' do
    before(:each) do
      @dummy_purpose = DvText.new(:value => 'dummy')
      @dummy_identity = double(PartyIdentity, :purpose => @dummy_purpose)
    end

    it 'should not have legal identity' do
      identity = double(PartyIdentity, :purpose => @dummy_purpose)
      identities = [identity, @dummy_identity].to_set
      @actor.identities = identities
      @actor.has_legal_identity?.should be_false
    end

    it 'should have legal identity' do
      legal_purpose = DvText.new(:value => 'legal identity')
      legal_identity = double(PartyIdentity, :purpose => legal_purpose)
      identities = [@dummy_identity, legal_identity].to_set
      @actor.identities = identities
      @actor.has_legal_identity?.should be_true
    end
  end
end

