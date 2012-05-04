require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvAmount do
  before(:each) do
    @dv_amount = DvAmount.new(:magnitude => 2,
                              :accuracy => 100,
                              :accuracy_percent => true)
  end

  it 'should be an instance of DvAmount' do
    @dv_amount.should be_an_instance_of DvAmount
  end

  it 's magnitude should be equal 2' do
    @dv_amount.magnitude.should be_equal 2
  end

  it 's accuracy should be 100 percent' do
    @dv_amount.accuracy.should be_equal 100
  end

  it 's accuracy_is_percent should be true' do
    @dv_amount.accuracy_is_percent?.should be_true
  end

  it 'should has an instance with nil accuracy' do
    dv_amount = DvAmount.new(:magnitude => 1)
    dv_amount.should be_an_instance_of DvAmount
  end

  it 'should be 3 if +2 magnitude DvAmount' do
    dv_amount4 = @dv_amount + DvAmount.new(:magnitude => 2)
    dv_amount4.magnitude.should == 4
  end

  it 'should be -1 if - 3 magnitude DvAmount' do
    dv_amount_1 = @dv_amount - DvAmount.new(:magnitude => 3)
    dv_amount_1.magnitude.should == -1
  end

  it 'should be type mismatch' do
    lambda {
      @dv_amount + 1
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError' do
    lambda {
      @dv_amount.set_accuracy(0, true)
    }.should_not raise_error ArgumentError
  end
  it 'should not raise ArgumentError' do
    lambda {
      @dv_amount.set_accuracy(50, true)
    }.should_not raise_error ArgumentError
  end

  it 'should not raise ArgumentError' do
    lambda {
      @dv_amount.set_accuracy(100, true)
    }.should_not raise_error ArgumentError
  end

  it 'should raise ArgumentError with invaild accuracy' do
    lambda {
      @dv_amount.set_accuracy(-0.01, true)
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with invaild accuracy' do
    lambda {
      @dv_amount.set_accuracy(100.1, true)
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError' do
    lambda {
      @dv_amount.set_accuracy(0, false)
    }.should_not raise_error ArgumentError
  end
  it 'should not raise ArgumentError' do
    lambda {
      @dv_amount.set_accuracy(0.5, false)
    }.should_not raise_error ArgumentError
  end

  it 'should not raise ArgumentError' do
    lambda {
      @dv_amount.set_accuracy(1.0, false)
    }.should_not raise_error ArgumentError
  end

  it 'should raise ArgumentError with invaild accuracy' do
    lambda {
      @dv_amount.set_accuracy(-0.01, false)
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with invaild accuracy' do
    lambda {
      @dv_amount.set_accuracy(1.01, false)
    }.should raise_error ArgumentError
  end
end
