require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe DvDate do
  before(:each) do
    @dv_date = DvDate.new(:value => '2009-09-28')
  end

  it 'should be an instance of DvDate' do
    @dv_date.should be_an_instance_of DvDate
  end

  it 'value should be' do
    @dv_date.value.should == '2009-09-28'
  end

  it 'year should be 2009' do
    @dv_date.year.should be_equal 2009
  end

  it 'month should be 9' do
    @dv_date.month.should be_equal 9
  end

  it 'day should be 28' do
    @dv_date.day.should be_equal 28
  end

  it 'magnitude should 734045' do
    @dv_date.magnitude.should == 734045
  end

  it 'diff should P0Y0M1W11D' do
    diff_date = DvDate.new(:value => '2009-10-09')
    @dv_date.diff(diff_date).value.should == 'P0Y0M1W11D'
  end

  it 'should process leap year' do
    @dv_date.value = '2004-02-28'
    diff_date = DvDate.new(:value => '2004-03-01')
    @dv_date.diff(diff_date).value.should == 'P0Y0M0W2D'
  end

  it 'should process year'do
    diff_date = DvDate.new(:value => '2007-12-31')
    @dv_date.diff(diff_date).value.should == 'P1Y8M4W28D'
  end

  it 'should be P0Y11M4W31D' do
    diff_date = DvDate.new(:value => '2008-09-30')
    @dv_date.diff(diff_date).value.should == 'P0Y11M4W29D'
  end

  it 'should be P1Y0M0W1D' do
    diff_date = DvDate.new(:value => '2010-09-29')
    @dv_date.diff(diff_date).value.should == 'P1Y0M0W1D'
  end

  it 'should be P0Y0M0W1D' do
    past_date = DvDate.new(:value => '2009-12-31')
    future_date=DvDate.new(:value => '2010-01-01')
    past_date.diff(future_date).value.should == 'P0Y0M0W1D'
  end
end
