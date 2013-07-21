require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe CDate do
  before(:all) do
    default_value = DvDate.new(:value => '2010-01-18')
    assumed_value = DvDate.new(:value => '2007-02-19')
    range = Interval.new(:lower => DvDate.new(:value => '2001-01-01'),
                         :upper => DvDate.new(:value => '2010-12-31'))
    @c_date = CDate.new(:default_value => default_value,
                        :assumed_value => assumed_value,
                        :range => range)
  end

  it 'should be an instance of CDate' do
    @c_date.should be_an_instance_of CDate
  end

  it 'range should be assigned properly' do
    @c_date.range.upper.month.should be_equal 12
  end

  it 'validity_is_range should be true if range is assigned' do
    @c_date.should be_validity_is_range
  end

  it 'raise ArgumentError unless range xor pattern' do
    expect { @c_date.range = nil }.to raise_exception
  end

  describe 'pattern attribute' do
    before(:all) do
      @c_date = CDate.new(:pattern => 'yyyy-mm-dd')
    end

    it 'pattern should be yyyy-mm-dd' do
      @c_date.pattern.should == 'yyyy-mm-dd'
    end
  end

  describe 'list attribute' do
    before(:all) do
      @c_date = CDate.new(:list => [DvDate.new(:value => '2011-11-28')])
    end

    it 'head of list is 2011-11-28' do
      @c_date.list[0].value.should == '2011-11-28'
    end
  end
end
