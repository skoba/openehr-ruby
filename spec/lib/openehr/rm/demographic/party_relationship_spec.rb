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
    @party_relationship.should be_an_instance_of PartyRelationship
  end

  it 'uid should be assigned properly' do
    @party_relationship.uid.value.should == '01'
  end

  it 'should raise ArgumentError when nil assigned to uid' do
    lambda {
      @party_relationship.uid = nil
    }.should raise_error ArgumentError
  end

  it 'details should be assigned properly' do
    @party_relationship.details.archetype_node_id.should == 'at0002'
  end

  it 'time_validity should be assigned properly' do
    @party_relationship.time_validity.upper.value.should == '2009-11-21'
  end

  it 'source should be_assigned properly' do
    @party_relationship.source.type.should == 'source'
  end

  it 'should raise ArgumentError when source is assinged nil' do
    lambda {
      @party_relationship.source = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when source is not matched with source' do
    invalid_id = ObjectID.new(:value => '10')
    invalid_source = double(PartyRef, :id => invalid_id)
    lambda {
      @party_relationship.source = invalid_source
    }.should raise_error ArgumentError
  end

  it 'target should be assined properly' do
    @party_relationship.target.id.value.should == '02'
  end

  it 'should raise ArgumentError with target is assigned by nil' do
    lambda {
      @party_relationship.target =nil
    }.should raise_error ArgumentError
  end

  it 'type should be inherited of name' do
    @party_relationship.type.value.should == 'party relation'
  end
end
  
                            
