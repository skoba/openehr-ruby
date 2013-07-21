require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataStructures::ItemStructure

describe Party do
  before(:each) do
    name = DvText.new(:value => 'PARTY')
    uid = HierObjectID.new(:value => '01')
    identities = double(Set, :empty? => false, :size => 2)
    contacts = double(Set, :size => 3, :empty? => false)
    cur_id = double(ObjectID, :value => '01')
    cur_source = double(PartyRef, :id => cur_id)
    id1 = double(ObjectID, :value => '03')
    targ1 = double(PartyRef, :id => id1)
    rel1 = double(PartyRelationship, :source => cur_source,
                :target => targ1)
    id2 = double(ObjectID, :value => '04')
    targ2 = double(PartyRef, :id => id2)
    rel2 = double(PartyRelationship, :source => cur_source,
                :target => targ2)
    id3 = double(ObjectID, :value => '05')
    targ3 = double(PartyRef, :id => id3) 
    rel3 = double(PartyRelationship, :source => cur_source,
                :target => targ3)
    id4 = double(ObjectID, :value => '06')
    targ4 = double(PartyRef, :id => id4)
    rel4 = double(PartyRelationship, :source => cur_source,
                :target => targ4)
    relationships = [rel1, rel2, rel3, rel4].to_set
    reverse_relationships = double(Set, :empty? => false, :size => 5)
    details = double(ItemStructure, :archetype_node_id => 'at0005')
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
    expect {
      @party.uid = nil
    }.to raise_error ArgumentError
  end

  it 'identities should be assigned properly' do
    @party.identities.size.should be_equal 2
  end

  it 'should raise ArgumentError when nil identities are assigned' do
    expect {
      @party.identities = nil
    }.to raise_error ArgumentError
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
    expect {
      @party.contacts = Set.new
    }.to raise_error ArgumentError
  end

  it 'relationships should be assigned properly' do
    target_ids = Set.new
    @party.relationships.each do |rel|
      target_ids << rel.target.id.value
    end
    target_ids.should == %w{03 04 05 06}.to_set
  end

  it 'should not raise ArgumentError with nil relationships' do
    expect {
      @party.relationships = nil
    }.not_to raise_error
  end

  it 'should raise ArgumentError with empty relationships' do
    expect {
      @party.relationships = Set.new
    }.to raise_error ArgumentError
  end

  it 'invaild relationship raise ArgumentError' do
    invalid_id = double(ObjectID, :value => '10')
    invalid_source = double(PartyRef, :id => invalid_id)
    invalid_rel = double(PartyRelationship, :source => invalid_source)
    expect {
      @party.relationships = [invalid_rel].to_set
    }.to raise_error ArgumentError
  end

  it 'reverse relationship should be assigned properly' do
    @party.reverse_relationships.size.should be_equal 5
  end

  it 'reverse_relationships should not be empty' do
    expect {
      @party.reverse_relationships = Set.new
    }.to raise_error ArgumentError
  end

  it 'should validate reverse_relationships'

  it 'details should be assigned properly' do
    @party.details.archetype_node_id.should == 'at0005'
  end
end

