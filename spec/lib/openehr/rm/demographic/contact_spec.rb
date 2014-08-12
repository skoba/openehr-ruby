require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::DataTypes::Text

describe Contact do
  before(:each) do
    name = DvText.new(:value => 'contact')
    addresses = double(Array, :size => 2, :empty? => false)
    upper = DvDate.new(:value => '2009-11-20')
    time_validity = double(DvInterval, :upper => upper)
    @contact = Contact.new(:archetype_node_id => 'at0000',
                           :name => name,
                           :addresses => addresses,
                           :time_validity => time_validity)
  end

  it 'should be an instance of Contact' do
    expect(@contact).to be_an_instance_of Contact
  end

  it 'addresses should be assigned properly' do
    expect(@contact.addresses.size).to eq(2)
  end

  it 'should raise ArgumentError with nil address' do
    expect {
      @contact.addresses = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty addresses' do
    expect {
      @contact.addresses = [ ]
    }.to raise_error ArgumentError
  end

  it 'time_validity should be assigned properly' do
    expect(@contact.time_validity.upper.value).to eq('2009-11-20')
  end

  it 'purpose should be inherit as name' do
    expect(@contact.purpose.value).to eq('contact')
  end
end
