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

  describe '#add / #subtract' do
    before(:each) do
      @plain_time = DvTime.new(:value => '10:00:00')
    end

    it 'adds an hour/minute duration' do
      expect(@plain_time.add(DvDuration.new(:value => 'PT1H30M')).value).to eq('11:30:00')
    end

    it 'wraps around a day boundary' do
      expect(@plain_time.add(DvDuration.new(:value => 'PT15H')).value).to eq('01:00:00')
    end

    it 'wraps backward past midnight' do
      expect(@plain_time.subtract(DvDuration.new(:value => 'PT11H')).value).to eq('23:00:00')
    end

    it 'adding a negative duration behaves like subtraction' do
      expect(@plain_time.add(DvDuration.new(:value => '-PT1H')).value).to eq('09:00:00')
    end

    it 'preserves the timezone' do
      result = @dv_time.add(DvDuration.new(:value => 'PT1H'))
      expect(result.value).to eq('12:17:30.2-0900')
    end

    it 'does not mutate the receiver' do
      _result = @plain_time.add(DvDuration.new(:value => 'PT1H'))
      expect(@plain_time.value).to eq('10:00:00')
    end

    it 'raises ArgumentError for a duration with a date component' do
      expect {
        @plain_time.add(DvDuration.new(:value => 'P1D'))
      }.to raise_error ArgumentError
    end

    it 'raises ArgumentError for a non-DvDuration operand' do
      expect {
        @plain_time.add(1)
      }.to raise_error ArgumentError
    end
  end
end
