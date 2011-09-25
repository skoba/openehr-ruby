require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::AssumedLibraryTypes

describe CDate do
  before(:each) do
    default_value = ISO8601Date.new('2010-01-18')
    assumed_value = ISO8601Date.new('2007-02-19')
    range = Interval.new(:lower => ISO8601Date.new('2001-01-01'),
                         :upper => ISO8601Date.new('2010-12-31'))
    @c_date = CDate.new(:default_value => default_value,
                        :assumed_value => assumed_value,
                        :range => range,
                        :month_validity => ValidityKind::MANDATORY,
                        :day_validity => ValidityKind::OPTIONAL,
                        :timezone_validity => ValidityKind::DISALLOWED)
  end

  it 'should be an instance of CDate' do
    @c_date.should be_an_instance_of CDate
  end

  it 'range should be assigned properly' do
    @c_date.range.upper.month.should be_equal 12
  end

  it 'month_validity should be assigned properly by constructor' do
    @c_date.month_validity.should be_equal ValidityKind::MANDATORY
  end

  it 'validity_is_range should be true if range is assigned' do
    @c_date.should be_validity_is_range
  end

  it 'validity_is_range should not be true if range is nil' do
    @c_date.range = nil
    @c_date.should_not be_validity_is_range
  end

  it 'day_validity should be assigned properly by constructor' do
    @c_date.day_validity.should be_equal ValidityKind::OPTIONAL
  end

  it 'timezone should be assigned properly' do
    @c_date.timezone_validity.should be_equal ValidityKind::DISALLOWED
  end

  describe 'method' do
    it 'month_validity should be assigned by method properly' do
      @c_date.month_validity = ValidityKind::OPTIONAL
      @c_date.month_validity.should be_equal ValidityKind::OPTIONAL
    end

    it 'day_validity should be assigned by method properly' do
      @c_date.day_validity = ValidityKind::MANDATORY
      @c_date.day_validity.should be_equal ValidityKind::MANDATORY
    end

    it 'should raise ArgumentError if month_validity is optional and day validity is mandatory' do
      @c_date.day_validity = ValidityKind::MANDATORY
      lambda {
        @c_date.month_validity = ValidityKind::OPTIONAL
      }.should raise_error ArgumentError
    end

    it 'should raise ArgumentError if month_validity is disallowed and day_validity is mandatory' do
      @c_date.day_validity = ValidityKind::MANDATORY
      lambda {
        @c_date.month_validity = ValidityKind::DISALLOWED
      }.should raise_error ArgumentError
    end

    it 'should raise ArgumentError if month_validity is disallowed and day_validity is optional' do
      lambda {
        @c_date.month_validity = ValidityKind::DISALLOWED
      }.should raise_error ArgumentError
    end
  end
end
