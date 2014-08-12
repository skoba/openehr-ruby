require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataStructures::ItemStructure

describe PartyRelationship do
  before(:each) do
    name = DvText.new(:value => 'party relation')
    uid = HierObjectID.new(:value => '01')
    details = double(ItemStructure, :archetype_node_id => 'at0002')
    upper = DvDate.new(:value => '2009-11-21')
    time_validity = double(DvInterval, :upper => upper)
    source_id = ObjectID.new(:value => '01')
    source = double(PartyRef, :id => source_id, :type => 'source')
    target_id = ObjectID.new(:value => '02')
    target = double(PartyRef, :id => target_id)
    @party_relationship =
      PartyRelationship.new(:archetype_node_id => 'at0000',
                            :name => name,
                            :uid => uid,
                            :details => details,
                            :time_validity => time_validity,
                            :source => source,
                            :target => target)
  end

  it 'should be an instance of PartyRelationship' do
    expect(@party_relationship).to be_an_instance_of PartyRelationship
  end

  it 'uid should be assigned properly' do
    expect(@party_relationship.uid.value).to eq('01')
  end

  it 'should raise ArgumentError when nil assigned to uid' do
    expect {
      @party_relationship.uid = nil
    }.to raise_error ArgumentError
  end

  it 'details should be assigned properly' do
    expect(@party_relationship.details.archetype_node_id).to eq('at0002')
  end

  it 'time_validity should be assigned properly' do
    expect(@party_relationship.time_validity.upper.value).to eq('2009-11-21')
  end

  it 'source should be_assigned properly' do
    expect(@party_relationship.source.type).to eq('source')
  end

  it 'should raise ArgumentError when source is assinged nil' do
    expect {
      @party_relationship.source = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when source is not matched with source' do
    invalid_id = ObjectID.new(:value => '10')
    invalid_source = double(PartyRef, :id => invalid_id)
    expect {
      @party_relationship.source = invalid_source
    }.to raise_error ArgumentError
  end

  it 'target should be assined properly' do
    expect(@party_relationship.target.id.value).to eq('02')
  end

  it 'should raise ArgumentError with target is assigned by nil' do
    expect {
      @party_relationship.target =nil
    }.to raise_error ArgumentError
  end

  it 'type should be inherited of name' do
    expect(@party_relationship.type.value).to eq('party relation')
  end
end
  
                            
