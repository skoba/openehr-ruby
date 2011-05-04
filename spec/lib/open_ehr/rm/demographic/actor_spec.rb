require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification

describe Actor do
  before(:each) do
    name = DvText.new(:value => 'actor')
    uid = HierObjectID.new(:value => '01')
    identities = stub(Set, :empty? => false)
    roles = stub(Set, :size => 2, :empty? => false)
    languages = stub(Array, :size => 3, :empty? => false)
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
    lambda {
      @actor.roles = Set.new
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil roles' do
    lambda {
      @actor.roles = nil
    }.should_not raise_error ArgumentError
  end

  it 'languages should be assigned properly' do
    @actor.languages.size.should be_equal 3
  end

  it 'should raise ArgumentError with empty languages' do
    lambda {
      @actor.languages = Set.new
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil languages' do
    lambda {
      @actor.languages = nil
    }.should_not raise_error ArgumentError
  end

  describe 'has_legal_identity' do
    before(:each) do
      @dummy_purpose = DvText.new(:value => 'dummy')
      @dummy_identity = stub(PartyIdentity, :purpose => @dummy_purpose)
    end

    it 'should not have legal identity' do
      identity = stub(PartyIdentity, :purpose => @dummy_purpose)
      identities = [identity, @dummy_identity].to_set
      @actor.identities = identities
      @actor.has_legal_identity?.should be_false
    end

    it 'should have legal identity' do
      legal_purpose = DvText.new(:value => 'legal identity')
      legal_identity = stub(PartyIdentity, :purpose => legal_purpose)
      identities = [@dummy_identity, legal_identity].to_set
      @actor.identities = identities
      @actor.has_legal_identity?.should be_true
    end
  end
end

