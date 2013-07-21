require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataStructures::ItemStructure

describe PartyIdentity do
  before(:each) do
    name = DvText.new(:value => 'test')
    details = double(ItemStructure, :archetype_node_id => 'at0002')
    @party_identity = PartyIdentity.new(:archetype_node_id => 'at0001',
                                        :name => name,
                                        :details => details)
  end

  it 'should be an instance of PartyIdentity' do
    @party_identity.should be_an_instance_of PartyIdentity
  end

  it 'details should be assigned properly' do
    @party_identity.details.archetype_node_id.should == 'at0002'
  end

  it 'should raise ArgumentError with nil details' do
    lambda {
      @party_identity.details = nil
    }.should raise_error ArgumentError
  end

  it 'purpose should return as same as name' do
    @party_identity.purpose.value.should == 'test'
  end
end
