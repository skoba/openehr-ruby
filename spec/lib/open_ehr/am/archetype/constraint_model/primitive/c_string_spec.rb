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
    @c_string.should be_an_instance_of CString
  end

  it 'type is always String' do
    @c_string.type.should == 'String'
  end

  it 'default should be assigned properly' do
    @c_string.default_value.value.should == 'default'
  end

  it 'assumed_value should be assigned properly' do
    @c_string.assumed_value.should == 'assumed'
  end

  it 'pattern should be assigned properly by constructor' do
    @c_string.pattern.should == 't[a-z]st'
  end

  it 'pattern should be assigned properly by method' do
    @c_string.pattern = '.*'
    @c_string.pattern.should == '.*'
  end

  it 'should raise ArgumentError if either list or pattern is not nil' do
    lambda {
      @c_string.list = ['test','driven']
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError if both list and pattern are nil' do
    lambda {
      @c_string.pattern = nil
    }.should raise_error ArgumentError
  end

  describe 'list attribute' do
    before(:each) do
      @default_value = DvText.new(:value => 'default')
      @c_string = CString.new(:default_value => @default_value,
                              :assumed_value => 'assumed',
                              :list => ['test', 'behavior'])
    end

    it 'list should be assigned properly by constructor' do
      @c_string.list.should == ['test', 'behavior']
    end

    it 'list shoudl be assigned properly by method' do
      @c_string.list = ['spec']
      @c_string.list.should == ['spec']
    end

    it 'should raise ArgumentError if both pattern and list is not nil' do
      lambda {
        @c_string.pattern = 'file.*'
      }.should raise_error ArgumentError
    end
  end
end
