require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'open_ehr/rm/data_types/quantity/date_time'
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe DvTemporal do
  before(:each) do
    @dv_temporal = DvTemporal.new(:value => '2009-09-28T23:36')
  end

  it 'should be an instance of DvTemporal' do
    @dv_temporal.should be_an_instance_of DvTemporal
  end

  it 'should raise ArgumentError with nil value' do
    lambda {
      @dv_temporal.value = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty value' do
    lambda {
      @dv_temporal.value = ''
    }.should raise_error ArgumentError
  end
end
