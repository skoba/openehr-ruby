require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataStructures::ItemStructure

describe Party do
  before(:each) do
    name = DvText.new(:value => 'PARTY')
    uid = HierObjectID.new(:value => '01')
    identities = stub(Set, :empty? => false, :size => 2)
    contacts = stub(Set, :size => 3, :empty? => false)
    cur_id = stub(ObjectID, :value => '01')
    cur_source = stub(PartyRef, :id => cur_id)
    id1 = stub(ObjectID, :value => '03')
    targ1 = stub(PartyRef, :id => id1)
    rel1 = stub(PartyRelationship, :source => cur_source,
                :target => targ1)
    id2 = stub(ObjectID, :value => '04')
    targ2 = stub(PartyRef, :id => id2)
    rel2 = stub(PartyRelationship, :source => cur_source,
                :target => targ2)
    id3 = stub(ObjectID, :value => '05')
    targ3 = stub(PartyRef, :id => id3) 
    rel3 = stub(PartyRelationship, :source => cur_source,
                :target => targ3)
    id4 = stub(ObjectID, :value => '06')
    targ4 = stub(PartyRef, :id => id4)
    rel4 = stub(PartyRelationship, :source => cur_source,
                :target => targ4)
    relationships = [rel1, rel2, rel3, rel4].to_set
    reverse_relationships = stub(Set, :empty? => false, :size => 5)
    details = stub(ItemStructure, :archetype_node_id => 'at0005')
    @party = Party.new(:archetype_node_id => 'at0001',
                       :name => name,
                       :uid => uid,
                       :identities => identities,
                       :contacts => contacts,
                       :relationships => relationships,
                       :reverse_relationships => reverse_relationships,
                       :details => details)
  end

  it 'should be an instance of Party' do
    @party.should be_an_instance_of Party
  end

  it 'uid should be assigned properly' do
    @party.uid.value.should == '01'
  end

  it 'should raise ArgumentError with nil uid' do
    lambda {
      @party.uid = nil
    }.should raise_error ArgumentError
  end

  it 'identities should be assigned properly' do
    @party.identities.size.should be_equal 2
  end

  it 'should raise ArgumentError when nil identities are assigned' do
    lambda {
      @party.identities = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when identities are empty' do
    expect {@party.identities = Set.new}.to raise_error
  end

  it 'type should be alias of name' do
    @party.type.value.should == 'PARTY'
  end

  it 'contacts should be assigned properly' do
    @party.contacts.size.should be_equal 3
  end

  it 'should raise ArgumentError with empty contacts' do
    lambda {
      @party.contacts = Set.new
    }.should raise_error ArgumentError
  end

  it 'relationships should be assigned properly' do
    target_ids = Set.new
    @party.relationships.each do |rel|
      target_ids << rel.target.id.value
    end
    target_ids.should == %w{03 04 05 06}.to_set
  end

  it 'should not raise ArgumentError with nil relationships' do
    lambda {
      @party.relationships = nil
    }.should_not raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty relationships' do
    lambda {
      @party.relationships = Set.new
    }.should raise_error ArgumentError
  end

  it 'invaild relationship raise ArgumentError' do
    invalid_id = stub(ObjectID, :value => '10')
    invalid_source = stub(PartyRef, :id => invalid_id)
    invalid_rel = stub(PartyRelationship, :source => invalid_source)
    lambda {
      @party.relationships = [invalid_rel].to_set
    }.should raise_error ArgumentError
  end

  it 'reverse relationship should be assigned properly' do
    @party.reverse_relationships.size.should be_equal 5
  end

  it 'reverse_relationships should not be empty' do
    lambda {
      @party.reverse_relationships = Set.new
    }.should raise_error ArgumentError
  end

  it 'should validate reverse_relationships'

  it 'details should be assigned properly' do
    @party.details.archetype_node_id.should == 'at0005'
  end
end

