require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe DvDateTime do
  before(:each) do
    @dv_date_time = DvDateTime.new(:value => '2009-09-29T15:03:22.3Z')
  end

  it 'should be an instance of DvDateTime' do
    expect(@dv_date_time).to be_an_instance_of DvDateTime
  end

  it 'magnitude should be 63423697018.3' do
    expect(@dv_date_time.magnitude).to be_within(0.01).of(63423697018.3)
  end

  it 'should be equal when magnitude is same' do
    expect(@dv_date_time).to eq(DvDateTime.new(:value => '2009-09-29T15:03:22.3Z'))
  end

  it 'diff should be caluculated from past to future' do
    future = DvDateTime.new(:value => '2009-10-29T16:23:30.3Z')
    expect(@dv_date_time.diff(future).value).to eq('P0Y1M0W0DT1H20M8.0S')
  end

  describe '#add / #subtract' do
    it 'adds an hour without crossing a day boundary' do
      result = @dv_date_time.add(DvDuration.new(:value => 'PT1H'))
      expect(result.value).to eq('2009-09-29T16:03:22.3Z')
    end

    it 'carries into the next day when the time overflows' do
      dv_date_time = DvDateTime.new(:value => '2009-09-29T23:00:00Z')
      result = dv_date_time.add(DvDuration.new(:value => 'PT2H'))
      expect(result.value).to eq('2009-09-30T01:00:00Z')
    end

    it 'adds a date component (with month-end clamping)' do
      dv_date_time = DvDateTime.new(:value => '2009-01-31T10:00:00Z')
      result = dv_date_time.add(DvDuration.new(:value => 'P1M'))
      expect(result.value).to eq('2009-02-28T10:00:00Z')
    end

    it 'subtracts, carrying into the previous day' do
      dv_date_time = DvDateTime.new(:value => '2009-09-29T01:00:00Z')
      result = dv_date_time.subtract(DvDuration.new(:value => 'PT2H'))
      expect(result.value).to eq('2009-09-28T23:00:00Z')
    end

    it 'adding a negative duration behaves like subtraction' do
      result = @dv_date_time.add(DvDuration.new(:value => '-PT1H'))
      expect(result.value).to eq('2009-09-29T14:03:22.3Z')
    end

    it 'does not mutate the receiver' do
      _result = @dv_date_time.add(DvDuration.new(:value => 'PT1H'))
      expect(@dv_date_time.value).to eq('2009-09-29T15:03:22.3Z')
    end

    it 'raises ArgumentError for a non-DvDuration operand' do
      expect {
        @dv_date_time.add(1)
      }.to raise_error ArgumentError
    end
  end
end
