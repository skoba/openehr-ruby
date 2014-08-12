require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe DvTime do
  before(:each) do
    @dv_time = DvTime.new(:value => '11:17:30.2-0900')
  end

  it 'should be an instance of DvTime' do
    expect(@dv_time).to be_an_instance_of DvTime
  end

  it 'hour should be 11' do
    expect(@dv_time.hour).to eq(11)
  end

  it 'minute should be 17' do
    expect(@dv_time.minute).to eq(17)
  end

  it 'second should be 30' do
    expect(@dv_time.second).to eq(30)
  end

  it 'fractional_second should be 0.2' do
    expect(@dv_time.fractional_second).to eq(0.2)
  end

  it 'timezone should be -0900' do
    expect(@dv_time.timezone).to eq('-0900')
  end

  it 'magnitude should 40650.2' do
    expect(@dv_time.magnitude).to eq(40650.2)
  end
  
  it 'should be ' do
    diff_time = DvTime.new(:value => '15:36:48.05')
    expect(@dv_time.diff(diff_time).value).to eq('P0Y0M0W0DT4H19M17.85S')
  end
end
