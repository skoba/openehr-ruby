require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AssumedLibraryTypes
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel::Primitive

describe CDateTime do
  before(:each) do
    default_value = ISO8601DateTime.new('2010-01-25T01:23:45.1')
    assumed_value = ISO8601DateTime.new('2001-12-23T22:02:33.2')
    range = Interval.new(:lower => ISO8601DateTime.new('1995-04-19T01:01:22'),
                         :upper => ISO8601DateTime.new('2022-12-31T23:55:59'))
    @c_date_time =
      CDateTime.new(:default_value => default_value,
                    :assumed_value => assumed_value,
                    :range => range,
                    :month_validity => ValidityKind::MANDATORY,
                    :day_validity => ValidityKind::MANDATORY,
                    :hour_vaildity => ValidityKind::MANDATORY,
                    :minute_validity => ValidityKind::MANDATORY,
                    :second_validity => ValidityKind::OPTIONAL,
                    :millisecond_validity => ValidityKind::DISALLOWED,
                    :timezone_validity => ValidityKind::OPTIONAL)
  end

  it 'should be an instance of CDateTime' do
    @c_date_time.should be_an_instance_of CDateTime
  end

  it 'hour_validity should be assigned properly' do
    @c_date_time.hour_validity.should be_equal ValidityKind::MANDATORY
  end

  it 'should raise ArgumentError if hour_validity is DISALLOWED and minute_validity is not DISALLOWED' do
    lambda {
      @c_date_time.hour_validity = ValidityKind::DISALLOWED
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError if hour_validity is DISALLOWED and minute_validity is DISALLOWED' do
    @c_date_time.second_validity = ValidityKind::DISALLOWED
    @c_date_time.minute_validity = ValidityKind::DISALLOWED
    lambda {
      @c_date_time.hour_validity = ValidityKind::DISALLOWED
    }.should_not raise_error ArgumentError
  end

  it 'should raise ArgumentError if hour_validity is OPTIONAL and minute_validity is MANDATORY' do
    lambda {
      @c_date_time.hour_validity = ValidityKind::OPTIONAL
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError if hour_validity is OPTIONAL and minute_validity is OPTIONAL' do
    @c_date_time.minute_validity = ValidityKind::OPTIONAL
    lambda {
      @c_date_time.hour_validity = ValidityKind::OPTIONAL
    }.should_not raise_error ArgumentError
  end

  it 'should not raise Argument Error if hour_validity is OPTIONAL and minute_validity is DISALLOWED' do
    @c_date_time.second_validity = ValidityKind::DISALLOWED
    @c_date_time.minute_validity = ValidityKind::DISALLOWED
    lambda {
      @c_date_time.hour_validity = ValidityKind::OPTIONAL
    }.should_not raise_error ArgumentError
  end

  it 'should raise ArgumentError if day_validity is DISALLOWED and hour_validity is not DISALLOWED' do
    lambda {
      @c_date_time.day_validity = ValidityKind::DISALLOWED
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError if day_validity is DISALLOWED and hour_validity is DISALLOWED' do
    @c_date_time.second_validity = ValidityKind::DISALLOWED
    @c_date_time.minute_validity = ValidityKind::DISALLOWED
    @c_date_time.hour_validity = ValidityKind::DISALLOWED
    lambda {
      @c_date_time.day_validity = ValidityKind::DISALLOWED
    }.should_not raise_error ArgumentError
  end

  it 'should raise ArgumentError if day_validity is OPTIONAL and hour_validity is MANDATORY' do
    lambda {
      @c_date_time.day_validity = ValidityKind::OPTIONAL
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError if day_validity OPTIONAL and hour_validity is OPTIONAL' do
    @c_date_time.second_validity = ValidityKind::DISALLOWED
    @c_date_time.minute_validity = ValidityKind::DISALLOWED
    @c_date_time.hour_validity = ValidityKind::OPTIONAL
    lambda {
      @c_date_time.day_validity = ValidityKind::OPTIONAL
    }.should_not raise_error ArgumentError
  end

  it 'should not raise ArgumentError if day_validity OPTIONAL and hour_validity is DISALLOWED' do
    @c_date_time.second_validity = ValidityKind::DISALLOWED
    @c_date_time.minute_validity = ValidityKind::DISALLOWED
    @c_date_time.hour_validity = ValidityKind::DISALLOWED
    lambda {
      @c_date_time.day_validity = ValidityKind::OPTIONAL
    }.should_not raise_error ArgumentError
  end
end
