require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AssumedLibraryTypes
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel::Primitive

describe CDuration do
  before(:each) do
    assumed_value = stub(ISO8601Duration, :year => 2)
    default_value = stub(ISO8601Duration, :month => 3)
    range = stub(Interval, :upper => assumed_value, :lower => default_value)
    @c_duration = CDuration.new(:assumed_value => assumed_value,
                                :default_value => default_value,
                                :type => 'Boolean',
                                :range => range,
                                :years_allowed => true,
                                :months_allowed => false,
                                :weeks_allowed => true,
                                :days_allowed => false,
                                :hours_allowed => true,
                                :minutes_allowed => false,
                                :seconds_allowed => true,
                                :fractional_seconds_allowed => false)
  end

  it 'should be an instance of CDuration' do
    @c_duration.should be_an_instance_of CDuration
  end

  it 'type is DvDuration' do
    @c_duration.type.should == 'Boolean'
  end

  it 'years_allowed should be assigned properly' do
    @c_duration.years_allowed.should be_true
  end

  it 'months_allowed should be assigned properly' do
    @c_duration.months_allowed.should be_false
  end

  it 'weeks_allowed should be assigned properly' do
    @c_duration.weeks_allowed.should be_true
  end

  it 'days_allowed should be assigned properly' do
    @c_duration.days_allowed.should be_false
  end

  it 'hours_allowed should be assigned properly' do
    @c_duration.hours_allowed.should be_true
  end

  it 'minutes_allowed should be assigned properly' do
    @c_duration.minutes_allowed.should be_false
  end

  it 'seconds_allowed should be assigned properly' do
    @c_duration.seconds_allowed.should be_true
  end

  it 'fractional_seconds_allowed should be assigned properly' do
    @c_duration.fractional_seconds_allowed.should be_false
  end

  it 'should raise ArgumentError if range is nil and all parameters are not allowed' do
    @c_duration.years_allowed = false
    @c_duration.weeks_allowed = false
    @c_duration.hours_allowed = false
    @c_duration.seconds_allowed = false
    lambda {
      @c_duration.range = nil
    }.should raise_error ArgumentError
  end
end
