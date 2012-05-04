require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe GenericID do
  before(:each) do
    @generic_id = GenericID.new(:value => '791-0245',
                                :scheme => 'ZIP')
  end

  it 'should be an instance of GenericID' do
    @generic_id.should be_an_instance_of GenericID
  end

  it 's value should be 791-0245' do
    @generic_id.value.should == '791-0245'
  end

  it 's scheme should be ZIP' do
    @generic_id.scheme.should == 'ZIP'
  end

  it 'should raise ArgumentError with nil scheme' do
    lambda {
      @generic_id.scheme = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty scheme' do
    lambda {
      @generic_id.scheme = ''
    }.should raise_error ArgumentError
  end
end
