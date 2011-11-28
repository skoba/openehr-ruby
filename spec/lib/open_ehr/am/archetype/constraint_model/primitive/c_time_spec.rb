require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AssumedLibraryTypes
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel::Primitive

describe CTime do
  before(:each) do
    default_value = ISO8601Time.new('01:23:45')
    assumed_value = ISO8601Time.new('22:02:33')
    range = Interval.new(:lower => ISO8601Time.new('01:01:22'),
                         :upper => ISO8601Time.new('23:55:59'))
    @c_time = CTime.new(:default_value => default_value,
                        :assumed_value => assumed_value,
                        :range => range,
                        :minute_validity => ValidityKind::MANDATORY,
                        :second_validity => ValidityKind::OPTIONAL,
                        :millisecond_validity => ValidityKind::DISALLOWED)
  end

  it 'should be an instance of CTime' do
    @c_time.should be_an_instance_of CTime
  end

  it 'type is DvTime' do
    @c_time.type.should == 'ISO8601_TIME'
  end

  it 'minute_validity should be assigned' do
    @c_time.minute_validity.should be_equal ValidityKind::MANDATORY
  end

  it 'seconds_validity should be assigned properly' do
    @c_time.second_validity.should be_equal ValidityKind::OPTIONAL
  end

  it 'millisecond_validity should be assigned properly' do
    @c_time.millisecond_validity.should be_equal ValidityKind::DISALLOWED
  end

  it 'should be true if range is not nil' do
    @c_time.should be_validity_is_range
  end

  it 'second_validity should not be MANDATORY if minute_validity is optional' do
    @c_time.second_validity = ValidityKind::MANDATORY
    lambda {
      @c_time.minute_validity = ValidityKind::OPTIONAL
    }.should raise_error ArgumentError
  end

  it 'second_validity should be DISALLOWED if minute_validity is DISALLOWED' do
    lambda {
      @c_time.minute_validity = ValidityKind::DISALLOWED
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError if minute_validity and second_validity are DISALLOWED' do
    @c_time.second_validity = ValidityKind::DISALLOWED
    lambda {
      @c_time.minute_validity = ValidityKind::DISALLOWED
    }.should_not raise_error ArgumentError
  end

  it 'millisecond_validity should not be MANDATORY if second_validity is optional' do
    @c_time.millisecond_validity = ValidityKind::MANDATORY
    lambda {
      @c_time.second_validity = ValidityKind::OPTIONAL
    }.should raise_error ArgumentError
  end

  it 'millisecond_validity should be DISALLOWED if second_validity is DISALLOWED' do
    lambda {
      @c_time.second_validity = ValidityKind::DISALLOWED
    }.should_not raise_error ArgumentError
  end

  it 'should raise ArgumentError if second_validity is DISALLOWED and millisecond_validity is OPTIONAL' do
    @c_time.millisecond_validity = ValidityKind::OPTIONAL
    lambda {
      @c_time.second_validity = ValidityKind::DISALLOWED
    }.should raise_error ArgumentError
  end
end
