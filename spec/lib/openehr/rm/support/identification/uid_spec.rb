require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Support::Identification

describe UID do
  before(:each) do
    @uid = UID.new(:value => '1001')
  end

  it 'should be an instance of UID' do
    expect(@uid).to be_an_instance_of UID
  end

  it 's value should be 1001' do
    expect(@uid.value).to eq('1001')
  end

  it 'should raise ArgumentError with nil value' do
    expect {
      @uid.value = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty value' do
    expect {
      @uid.value = ''
    }.to raise_error ArgumentError
  end
end
  
