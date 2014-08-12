require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe GenericID do
  before(:each) do
    @generic_id = GenericID.new(:value => '791-0245',
                                :scheme => 'ZIP')
  end

  it 'should be an instance of GenericID' do
    expect(@generic_id).to be_an_instance_of GenericID
  end

  it 's value should be 791-0245' do
    expect(@generic_id.value).to eq('791-0245')
  end

  it 's scheme should be ZIP' do
    expect(@generic_id.scheme).to eq('ZIP')
  end

  it 'should raise ArgumentError with nil scheme' do
    expect {
      @generic_id.scheme = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty scheme' do
    expect {
      @generic_id.scheme = ''
    }.to raise_error ArgumentError
  end
end
