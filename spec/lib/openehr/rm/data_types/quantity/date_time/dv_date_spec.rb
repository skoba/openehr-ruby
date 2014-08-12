require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe DvDate do
  before(:each) do
    @dv_date = DvDate.new(:value => '2009-09-28')
  end

  it 'should be an instance of DvDate' do
    expect(@dv_date).to be_an_instance_of DvDate
  end

  it 'value should be' do
    expect(@dv_date.value).to eq('2009-09-28')
  end

  it 'year should be 2009' do
    expect(@dv_date.year).to be_equal 2009
  end

  it 'month should be 9' do
    expect(@dv_date.month).to be_equal 9
  end

  it 'day should be 28' do
    expect(@dv_date.day).to be_equal 28
  end

  it 'magnitude should 734045' do
    expect(@dv_date.magnitude).to eq(734045)
  end

  it 'diff should P0Y0M1W11D' do
    diff_date = DvDate.new(:value => '2009-10-09')
    expect(@dv_date.diff(diff_date).value).to eq('P0Y0M1W11D')
  end

  it 'should process leap year' do
    @dv_date.value = '2004-02-28'
    diff_date = DvDate.new(:value => '2004-03-01')
    expect(@dv_date.diff(diff_date).value).to eq('P0Y0M0W2D')
  end

  it 'should process year'do
    diff_date = DvDate.new(:value => '2007-12-31')
    expect(@dv_date.diff(diff_date).value).to eq('P1Y8M4W28D')
  end

  it 'should be P0Y11M4W31D' do
    diff_date = DvDate.new(:value => '2008-09-30')
    expect(@dv_date.diff(diff_date).value).to eq('P0Y11M4W29D')
  end

  it 'should be P1Y0M0W1D' do
    diff_date = DvDate.new(:value => '2010-09-29')
    expect(@dv_date.diff(diff_date).value).to eq('P1Y0M0W1D')
  end

  it 'should be P0Y0M0W1D' do
    past_date = DvDate.new(:value => '2009-12-31')
    future_date=DvDate.new(:value => '2010-01-01')
    expect(past_date.diff(future_date).value).to eq('P0Y0M0W1D')
  end
end
