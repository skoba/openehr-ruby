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

  it 'should allow both range and list to be nil (unconstrained/any_allowed)' do
    expect {
      @c_integer.list = nil
    }.not_to raise_error
    expect(@c_integer.list).to be_nil
    expect(@c_integer.range).to be_nil
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

  describe '#valid_value?' do
    it 'is true for a value in the list' do
      expect(@c_integer.valid_value?(1)).to be true
    end

    it 'is false for a value not in the list' do
      expect(@c_integer.valid_value?(99)).to be false
    end

    it 'is false for a non-Integer' do
      expect(@c_integer.valid_value?(1.5)).to be false
    end

    it 'is true for any Integer when unconstrained' do
      c_integer = CInteger.new
      expect(c_integer.valid_value?(-999)).to be true
    end

    it 'checks the range when a range constraint is set' do
      c_integer = CInteger.new(:range => Interval.new(:lower => 0, :upper => 5))
      expect(c_integer.valid_value?(3)).to be true
      expect(c_integer.valid_value?(6)).to be false
    end
  end
end
