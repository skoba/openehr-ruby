require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::AssumedLibraryTypes

describe CInteger do
  before(:each) do
    @c_integer = CInteger.new(:default_value => 3,
                              :assumed_value => 2,
                              :type => 'Integer',
                              :list => [1,2])
  end

  it 'should be an instance of CInteger' do
    @c_integer.should be_an_instance_of CInteger
  end

  it 'type is DvInteger' do
    @c_integer.type.should == 'Integer'
  end

  it 'should raise ArgumentError if both range and list are nil' do
    lambda {
      @c_integer.list = nil
    }.should raise_error ArgumentError
  end

  describe 'list method' do
    it 'constructor should assign list properly' do
      @c_integer.list.should == [1,2]
    end

    it 'list method should re-assign properly' do
      @c_integer.list = [2,3]
      @c_integer.list.should == [2,3]
    end

    it 'should be raise ArgumentError if both list and range are not nil' do
      lambda {
        @c_integer.range = Interval.new(:lower => 1,:upper =>3)
      }.should raise_error ArgumentError
    end
  end

  describe 'range mathod' do
    before(:each) do
      @c_integer =
        CInteger.new(:default_value => 2,
                     :assumed_value => 3,
                     :range => Interval.new(:lower => 0, :upper => 5))
    end

    it 'constructor should assign range properly' do
      @c_integer.range.lower.should be_equal 0
    end

    it 'range method should re-assigne properly' do
      @c_integer.range = Interval.new(:lower => 20)
      @c_integer.range.lower.should be_equal 20
    end

    it 'should raise ArgumentError if bhot range and list are not nil' do
      lambda {
        @c_integer.list = [10,100]
      }.should raise_error ArgumentError
    end
  end
end
