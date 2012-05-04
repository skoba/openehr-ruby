require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::DataTypes::Text

describe Contact do
  before(:each) do
    name = DvText.new(:value => 'contact')
    addresses = stub(Array, :size => 2, :empty? => false)
    upper = DvDate.new(:value => '2009-11-20')
    time_validity = stub(DvInterval, :upper => upper)
    @contact = Contact.new(:archetype_node_id => 'at0000',
                           :name => name,
                           :addresses => addresses,
                           :time_validity => time_validity)
  end

  it 'should be an instance of Contact' do
    @contact.should be_an_instance_of Contact
  end

  it 'addresses should be assigned properly' do
    @contact.addresses.size.should == 2
  end

  it 'should raise ArgumentError with nil address' do
    lambda {
      @contact.addresses = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty addresses' do
    lambda {
      @contact.addresses = [ ]
    }.should raise_error ArgumentError
  end

  it 'time_validity should be assigned properly' do
    @contact.time_validity.upper.value.should == '2009-11-20'
  end

  it 'purpose should be inherit as name' do
    @contact.purpose.value.should == 'contact'
  end
end
