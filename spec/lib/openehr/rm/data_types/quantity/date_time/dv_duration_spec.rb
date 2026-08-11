require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe DvDate do
  before(:each) do
    @dv_duration = DvDuration.new(:value => 'P1Y2M3W4DT5H6M7.7S')
  end

  it 'is an instance of DvDuration' do
    expect(@dv_duration).to be_an_instance_of DvDuration
  end

  it 'year is 1' do
    expect(@dv_duration.years).to be 1
  end

  it 'months is 2' do
    expect(@dv_duration.months).to be 2
  end

  it 'weeks is 3' do
    expect(@dv_duration.weeks).to be 3
  end

  it 'days is 4' do
    expect(@dv_duration.days).to be 4
  end

  it 'hours should be 5' do
    expect(@dv_duration.hours).to be 5
  end

  it 'minutes should be 6' do
    expect(@dv_duration.minutes).to be 6
  end

  it 'seconds should be 7' do
    expect(@dv_duration.seconds).to be 7
  end

  it 'fractional_second should be 0.7' do
    expect(@dv_duration.fractional_second).to eq(0.7)
  end

  # RM 1.1.0 (SPECRM-96): consistently support negative durations, e.g.
  # for adjusted age (a premature newborn's age relative to full-term).
  describe 'negative durations' do
    it 'is negative? false for a positive duration' do
      expect(@dv_duration).not_to be_negative
    end

    it 'parses a negative duration' do
      dv_duration = DvDuration.new(:value => '-P10D')
      expect(dv_duration).to be_negative
      expect(dv_duration.days).to eq(10)
    end

    it 'negates magnitude for a negative duration' do
      dv_duration = DvDuration.new(:value => '-P1D')
      expect(dv_duration.magnitude).to eq(-86400)
    end

    it 'supports unary minus (DV_AMOUNT.negative), returning a new DvDuration with the sign flipped' do
      negated = -DvDuration.new(:value => 'P1D')
      expect(negated).to be_negative
      expect(negated.magnitude).to eq(-86400)
    end

    it 'unary minus on an already-negative duration flips back to positive' do
      negated = -DvDuration.new(:value => '-P1D')
      expect(negated).not_to be_negative
      expect(negated.magnitude).to eq(86400)
    end
  end
end
