require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataStructures::ItemStructure

describe Capability do
  before(:each) do
    name = DvText.new(:value => 'party relation')
    credentials = stub(ItemStructure, :archetype_node_id => 'at0001')
    lower = DvDate.new(:value => '2009-11-21')
    time_validity = stub(DvInterval, :lower => lower)
    @capability = Capability.new(:archetype_node_id => 'at0000',
                                 :name => name,
                                 :credentials => credentials,
                                 :time_validity => time_validity)
  end

  it 'should be an instance of Capability' do
    @capability.should be_an_instance_of Capability
  end

  it 'credential should be assigned properly' do
    @capability.credentials.archetype_node_id.should == 'at0001'
  end

  it 'should raise ArgumentError when nil assigned to credentials' do
    lambda {
      @capability.credentials = nil
    }.should raise_error ArgumentError
  end

  it 'time_validity should be assigned properly' do
    @capability.time_validity.lower.value.should == '2009-11-21'
  end
end
