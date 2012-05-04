require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::Support::Identification

describe Role do
  before(:each) do
    name = DvText.new(:value => 'role')
    uid = HierObjectID.new(:value => '01')
    identities = stub(Set, :empty? => false)
    capabilities = stub(Array, :size => 2, :empty? => false)
    lower = DvDate.new(:value => '2009-11-21')
    time_validity = stub(DvInterval, :lower => lower)
    performer = stub(PartyRef, :type => 'ROLE')
    @role = Role.new(:archetype_node_id => 'at0000',
                     :name => name,
                     :uid => uid,
                     :identities => identities,
                     :performer => performer,
                     :capabilities => capabilities,
                     :time_validity => time_validity)
  end

  it 'should be an instance of Role' do
    @role.should be_an_instance_of Role
  end

  it 'performer should assigned properly' do
    @role.performer.type.should == 'ROLE'
  end

  it 'should raise ArgumentError with nil performer' do
    lambda {
      @role.performer = nil
    }.should raise_error ArgumentError
  end

  it 'capabilities should be assigned properly' do
    @role.capabilities.size.should be_equal 2
  end

  it 'should raise ArgumentError with empty capabilities' do
    lambda {
      @role.capabilities = [ ]
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil capabilities' do
    lambda {
      @role.capabilities = nil
    }.should_not raise_error ArgumentError
  end

  it 'time_validity should be properly assigned' do
    @role.time_validity.lower.value.should == '2009-11-21'
  end
end
