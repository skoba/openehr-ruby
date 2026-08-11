require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::AssumedLibraryTypes
include OpenEHR::AM::Archetype::ConstraintModel::Primitive

describe CDuration do
  before(:all) do
    assumed_value = DvDuration.new(:value => 'P2Y')
    default_value = DvDuration.new(:value => 'P3M')
    range = Interval.new(:upper => assumed_value, :lower => default_value)
    @c_duration = CDuration.new(:assumed_value => assumed_value,
                                :default_value => default_value,
                                :range => range)
  end

  it 'should be an instance of CDuration' do
    expect(@c_duration).to be_an_instance_of CDuration
  end

  it 'type is ISO8601_DURATION' do
    expect(@c_duration.type).to eq('ISO8601_DURATION')
  end

  it 'upper range is 2 years' do
    expect(@c_duration.range.upper.value).to eq('P2Y')
  end

  it 'lower range is 3 months year' do
    expect(@c_duration.range.lower.value).to eq('P3M')
  end

  context 'list constraint' do
    before(:all) do
      @c_duration = CDuration.new(:list => [DvDuration.new(:value => 'PT0s')])
    end

    it '1st item of the list value is PT0s' do
      expect(@c_duration.list[0].value).to eq('PT0s')
    end
  end

  describe '#valid_value?' do
    it 'is true for a value within the range' do
      within_range = DvDuration.new(:value => 'P1Y')
      expect(@c_duration.valid_value?(within_range)).to be true
    end

    it 'is false for a value outside the range' do
      outside_range = DvDuration.new(:value => 'P10Y')
      expect(@c_duration.valid_value?(outside_range)).to be false
    end

    it 'accepts an ISO8601 duration string too' do
      expect(@c_duration.valid_value?('P1Y')).to be true
    end

    it 'is true for any duration when unconstrained' do
      c_duration = CDuration.new
      expect(c_duration.valid_value?('P100Y')).to be true
    end

    it 'is false when a disallowed field is present in the value' do
      c_duration = CDuration.new(:weeks_allowed => false)
      expect(c_duration.valid_value?('P2W')).to be false
      expect(c_duration.valid_value?('P2D')).to be true
    end
  end
end
