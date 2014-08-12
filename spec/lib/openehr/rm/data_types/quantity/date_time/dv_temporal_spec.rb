require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe DvTemporal do
  before(:each) do
    @dv_temporal = DvTemporal.new(:value => '2009-09-28T23:36')
  end

  it 'should be an instance of DvTemporal' do
    expect(@dv_temporal).to be_an_instance_of DvTemporal
  end

  it 'should raise ArgumentError with nil value' do
    expect {
      @dv_temporal.value = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty value' do
    expect {
      @dv_temporal.value = ''
    }.to raise_error ArgumentError
  end
end
