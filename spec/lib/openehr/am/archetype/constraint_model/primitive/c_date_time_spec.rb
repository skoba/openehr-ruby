require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe CDateTime do
  before(:each) do
    default_value = DvDateTime.new(:value => '2010-01-25T01:23:45.1')
    assumed_value = DvDateTime.new(:value => '2001-12-23T22:02:33.2')
    range = Interval.new(:lower => DvDateTime.new(:value =>'1995-04-19T01:01:22'),
                         :upper => DvDateTime.new(:value => '2022-12-31T23:55:59'))
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
    expect(@c_date_time).to be_an_instance_of CDateTime
  end

  it 'type is ISO8601_DATE_TIME' do
    expect(@c_date_time.type).to eq('ISO8601_DATE_TIME')
  end

  it 'hour_validity should be assigned properly' do
    expect(@c_date_time.hour_validity).to be_equal ValidityKind::MANDATORY
  end

  it 'should raise ArgumentError if hour_validity is DISALLOWED and minute_validity is not DISALLOWED' do
    expect {
      @c_date_time.hour_validity = ValidityKind::DISALLOWED
    }.to raise_error ArgumentError
  end

  it 'range is properly assigned, lower value is 1995-04-19T01:01:22' do
    expect(@c_date_time.range.lower.value).to eq('1995-04-19T01:01:22')
  end


  it 'should not raise ArgumentError if hour_validity is DISALLOWED and minute_validity is DISALLOWED' do
    @c_date_time.second_validity = ValidityKind::DISALLOWED
    @c_date_time.minute_validity = ValidityKind::DISALLOWED
    expect {
      @c_date_time.hour_validity = ValidityKind::DISALLOWED
    }.not_to raise_error
  end

  it 'should raise ArgumentError if hour_validity is OPTIONAL and minute_validity is MANDATORY' do
    expect {
      @c_date_time.hour_validity = ValidityKind::OPTIONAL
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError if hour_validity is OPTIONAL and minute_validity is OPTIONAL' do
    @c_date_time.minute_validity = ValidityKind::OPTIONAL
    expect {
      @c_date_time.hour_validity = ValidityKind::OPTIONAL
    }.not_to raise_error
  end

  it 'should not raise Argument Error if hour_validity is OPTIONAL and minute_validity is DISALLOWED' do
    @c_date_time.second_validity = ValidityKind::DISALLOWED
    @c_date_time.minute_validity = ValidityKind::DISALLOWED
    expect {
      @c_date_time.hour_validity = ValidityKind::OPTIONAL
    }.not_to raise_error
  end

  it 'should raise ArgumentError if day_validity is DISALLOWED and hour_validity is not DISALLOWED' do
    expect {
      @c_date_time.day_validity = ValidityKind::DISALLOWED
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError if day_validity is DISALLOWED and hour_validity is DISALLOWED' do
    @c_date_time.second_validity = ValidityKind::DISALLOWED
    @c_date_time.minute_validity = ValidityKind::DISALLOWED
    @c_date_time.hour_validity = ValidityKind::DISALLOWED
    expect {
      @c_date_time.day_validity = ValidityKind::DISALLOWED
    }.not_to raise_error
  end

  it 'should raise ArgumentError if day_validity is OPTIONAL and hour_validity is MANDATORY' do
    expect {
      @c_date_time.day_validity = ValidityKind::OPTIONAL
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError if day_validity OPTIONAL and hour_validity is OPTIONAL' do
    @c_date_time.second_validity = ValidityKind::DISALLOWED
    @c_date_time.minute_validity = ValidityKind::DISALLOWED
    @c_date_time.hour_validity = ValidityKind::OPTIONAL
    expect {
      @c_date_time.day_validity = ValidityKind::OPTIONAL
    }.not_to raise_error
  end

  it 'should not raise ArgumentError if day_validity OPTIONAL and hour_validity is DISALLOWED' do
    @c_date_time.second_validity = ValidityKind::DISALLOWED
    @c_date_time.minute_validity = ValidityKind::DISALLOWED
    @c_date_time.hour_validity = ValidityKind::DISALLOWED
    expect {
      @c_date_time.day_validity = ValidityKind::OPTIONAL
    }.not_to raise_error
  end

  describe 'pattern constraint' do
    before(:all) do
      @c_date_timep = CDateTime.new(:pattern => 'yyyy-mm-dd hh:mm:ss')
    end

    it 'pattern is yyyy-mm-dd hh:mm:ss' do
      expect(@c_date_timep.pattern).to eq('yyyy-mm-dd hh:mm:ss')
    end
  end

  describe 'list constraint' do
    before(:all) do
      @c_date_timel = CDateTime.new(:list =>
                [DvDateTime.new(:value => '2010-01-25T01:23:45.1')])
    end

    it 'first item of list is 2010-01-25T01:23:45.1' do
      expect(@c_date_timel.list[0].value).to eq('2010-01-25T01:23:45.1')
    end
  end
end
