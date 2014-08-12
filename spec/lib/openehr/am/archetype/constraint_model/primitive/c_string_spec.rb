require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::RM::DataTypes::Text

describe CString do
  before(:each) do
    @default_value = DvText.new(:value => 'default')
    @c_string = CString.new(:default_value => @default_value,
                            :assumed_value => 'assumed',
                            :pattern => 't[a-z]st')
  end

  it 'should be an instance of CString' do
    expect(@c_string).to be_an_instance_of CString
  end

  it 'type is always String' do
    expect(@c_string.type).to eq('String')
  end

  it 'default should be assigned properly' do
    expect(@c_string.default_value.value).to eq('default')
  end

  it 'assumed_value should be assigned properly' do
    expect(@c_string.assumed_value).to eq('assumed')
  end

  it 'pattern should be assigned properly by constructor' do
    expect(@c_string.pattern).to eq('t[a-z]st')
  end

  it 'pattern should be assigned properly by method' do
    @c_string.pattern = '.*'
    expect(@c_string.pattern).to eq('.*')
  end

  it 'should raise ArgumentError if either list or pattern is not nil' do
    expect {
      @c_string.list = ['test','driven']
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError if both list and pattern are nil' do
    expect {
      @c_string.pattern = nil
    }.to raise_error ArgumentError
  end

  describe 'list attribute' do
    before(:each) do
      @default_value = DvText.new(:value => 'default')
      @c_string = CString.new(:default_value => @default_value,
                              :assumed_value => 'assumed',
                              :list => ['test', 'behavior'])
    end

    it 'list should be assigned properly by constructor' do
      expect(@c_string.list).to eq(['test', 'behavior'])
    end

    it 'list shoudl be assigned properly by method' do
      @c_string.list = ['spec']
      expect(@c_string.list).to eq(['spec'])
    end

    it 'should raise ArgumentError if both pattern and list is not nil' do
      expect {
        @c_string.pattern = 'file.*'
      }.to raise_error ArgumentError
    end
  end
end
