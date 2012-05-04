require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe UID do
  before(:each) do
    @uid = UID.new(:value => '1001')
  end

  it 'should be an instance of UID' do
    @uid.should be_an_instance_of UID
  end

  it 's value should be 1001' do
    @uid.value.should == '1001'
  end

  it 'should raise ArgumentError with nil value' do
    lambda {
      @uid.value = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty value' do
    lambda {
      @uid.value = ''
    }.should raise_error ArgumentError
  end
end
  
