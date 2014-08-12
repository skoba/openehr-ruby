require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvAmount do
  before(:each) do
    @dv_amount = DvAmount.new(:magnitude => 2,
                              :accuracy => 100,
                              :accuracy_percent => true)
  end

  it 'should be an instance of DvAmount' do
    expect(@dv_amount).to be_an_instance_of DvAmount
  end

  it 's magnitude should be equal 2' do
    expect(@dv_amount.magnitude).to be_equal 2
  end

  it 's accuracy should be 100 percent' do
    expect(@dv_amount.accuracy).to be_equal 100
  end

  it 's accuracy_is_percent should be true' do
    expect(@dv_amount.accuracy_is_percent?).to be_truthy
  end

  it 'should has an instance with nil accuracy' do
    dv_amount = DvAmount.new(:magnitude => 1)
    expect(dv_amount).to be_an_instance_of DvAmount
  end

  it 'should be 3 if +2 magnitude DvAmount' do
    dv_amount4 = @dv_amount + DvAmount.new(:magnitude => 2)
    expect(dv_amount4.magnitude).to eq(4)
  end

  it 'should be -1 if - 3 magnitude DvAmount' do
    dv_amount_1 = @dv_amount - DvAmount.new(:magnitude => 3)
    expect(dv_amount_1.magnitude).to eq(-1)
  end

  it 'should be type mismatch' do
    expect {
      @dv_amount + 1
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError' do
    expect {
      @dv_amount.set_accuracy(0, true)
    }.not_to raise_error
  end
  it 'should not raise ArgumentError' do
    expect {
      @dv_amount.set_accuracy(50, true)
    }.not_to raise_error
  end

  it 'should not raise ArgumentError' do
    expect {
      @dv_amount.set_accuracy(100, true)
    }.not_to raise_error
  end

  it 'should raise ArgumentError with invaild accuracy' do
    expect {
      @dv_amount.set_accuracy(-0.01, true)
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with invaild accuracy' do
    expect {
      @dv_amount.set_accuracy(100.1, true)
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError' do
    expect {
      @dv_amount.set_accuracy(0, false)
    }.not_to raise_error
  end
  it 'should not raise ArgumentError' do
    expect {
      @dv_amount.set_accuracy(0.5, false)
    }.not_to raise_error
  end

  it 'should not raise ArgumentError' do
    expect {
      @dv_amount.set_accuracy(1.0, false)
    }.not_to raise_error
  end

  it 'should raise ArgumentError with invaild accuracy' do
    expect {
      @dv_amount.set_accuracy(-0.01, false)
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with invaild accuracy' do
    expect {
      @dv_amount.set_accuracy(1.01, false)
    }.to raise_error ArgumentError
  end
end
