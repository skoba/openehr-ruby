require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe ReferenceRange do
  before(:each) do
    dv_interval ||= double(DvInterval)
    @mock_dv_interval ||= double('dv_interval')
    @reference_range = ReferenceRange.new(:meaning => 'test',
                                          :range => dv_interval)
  end

  it 'should be an instance of DvInterval' do
    expect(@reference_range).to be_an_instance_of ReferenceRange
  end

  it 's meaning should be test' do
    expect(@reference_range.meaning).to eq('test')
  end

  it 'should be in range' do
    expect(@mock_dv_interval).to receive(:has?).with(1).and_return(true)
    @reference_range.range = @mock_dv_interval
    expect(@reference_range.is_in_range?(1)).to be_truthy
  end

  it 'should be out of range' do
    expect(@mock_dv_interval).to receive(:has?).with(-1).and_return(false)
    @reference_range.range = @mock_dv_interval
    expect(@reference_range.is_in_range?(-1)).to be_falsey
  end

  it 'should raise ArgumentError with nil meaning' do
    expect {
      @reference_range.meaning = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil range' do
    expect {
      @reference_range.range = nil
    }.to raise_error ArgumentError
  end
end
