require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CAttribute do
  before(:each) do
    existence = Interval.new(:lower => 0, :upper => 1)
    parent = stub(CObject, :path => '/event[at0001]')
    occurrences = existence
    children = [CObject.new(:rm_type_name => 'DV_AMOUNT',
                            :path => '/event[at0001]/data',
                            :occurrences => occurrences)]
    @c_attribute = CAttribute.new(:parent => parent,
                                  :rm_attribute_name => 'data',
                                  :path => '/event[at0001]/data',
                                  :existence => existence,
                                  :children => children)
  end

  it 'should be an instance of CAttribute' do
    @c_attribute.should be_an_instance_of CAttribute
  end

  it 'rm_attribute_name should be assigned properly' do
    @c_attribute.rm_attribute_name.should == 'data'
  end

  it 'should raise ArguemntError rm_attribute_name is empty' do
    lambda {
      @c_attribute.rm_attribute_name = ''
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError rm_attribute_name is nil' do
    lambda {
      @c_attribute.rm_attribute_name = nil
    }.should raise_error ArgumentError
  end

  it 'existence should be assigned properly' do
    @c_attribute.existence.lower.should be_equal 0
  end

  it 'existence.lower should be more than 0' do
    invalid_existence = Interval.new(:lower => -1, :upper => 1)
    lambda {
      @c_attribute.existence = invalid_existence
    }.should raise_error ArgumentError
  end

  it 'existence.upper should be equal or less than 1' do
    invalid_existence = Interval.new(:lower => 0, :upper => 2)
    lambda {
      @c_attribute.existence = invalid_existence
    }.should raise_error ArgumentError
  end

  it 'children should be assigned properly' do
    @c_attribute.children[0].rm_type_name.should == 'DV_AMOUNT'
  end

  it 'children parent should be set properly' do
    @c_attribute.children[0].parent.should == @c_attribute
  end
end



