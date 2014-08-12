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
    expect(@c_integer).to be_an_instance_of CInteger
  end

  it 'type is DvInteger' do
    expect(@c_integer.type).to eq('Integer')
  end

  it 'should raise ArgumentError if both range and list are nil' do
    expect {
      @c_integer.list = nil
    }.to raise_error ArgumentError
  end

  describe 'list method' do
    it 'constructor should assign list properly' do
      expect(@c_integer.list).to eq([1,2])
    end

    it 'list method should re-assign properly' do
      @c_integer.list = [2,3]
      expect(@c_integer.list).to eq([2,3])
    end

    it 'should be raise ArgumentError if both list and range are not nil' do
      expect {
        @c_integer.range = Interval.new(:lower => 1,:upper =>3)
      }.to raise_error ArgumentError
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
      expect(@c_integer.range.lower).to be_equal 0
    end

    it 'range method should re-assigne properly' do
      @c_integer.range = Interval.new(:lower => 20)
      expect(@c_integer.range.lower).to be_equal 20
    end

    it 'should raise ArgumentError if bhot range and list are not nil' do
      expect {
        @c_integer.list = [10,100]
      }.to raise_error ArgumentError
    end
  end
end
