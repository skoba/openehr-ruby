require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe DvDateTime do
  before(:each) do
    @dv_date_time = DvDateTime.new(:value => '2009-09-29T15:03:22.3')
  end

  it 'should be an instance of DvDateTime' do
    @dv_date_time.should be_an_instance_of DvDateTime
  end

  it 'magnitude should be 63425495002.3' do
    @dv_date_time.magnitude.should be_within(0.01).of(63423697018.3)
  end

  it 'should be equal when magnitude is same' do
    @dv_date_time.should == DvDateTime.new(:value => '2009-09-29T15:03:22.3')
  end

  it 'diff should be caluculated from past to future' do
    future = DvDateTime.new(:value => '2009-10-29T16:23:30.3')
    @dv_date_time.diff(future).value.should == 'P0Y1M0W0DT1H20M8.0S'
  end
end
