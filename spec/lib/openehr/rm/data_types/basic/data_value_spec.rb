require File.dirname(__FILE__) + '/../../../../../spec_helper'

include OpenEHR::RM::DataTypes::Basic

describe DataValue do
  before(:each) do
    @data_value = DataValue.new(:value => 'ANY')
  end

  it 'should be an instance of DataValue' do
    @data_value.should be_an_instance_of DataValue
  end

  it 's value should be stub' do
    @data_value.value.should == 'ANY'
  end
end
