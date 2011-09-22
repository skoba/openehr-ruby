require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::RM::DataTypes::Text

describe CPrimitive do
  before(:each) do
    default = DvText.new(:value => 'DEFAULT')
    assumed = DvText.new(:value => 'ASSUMED')
    @c_primitive = CPrimitive.new(:default_value => default,
                                  :assumed_value => assumed)
  end

  it 'should be an instance of CPrimitive' do
    @c_primitive.should be_an_instance_of CPrimitive
  end

  it 'type is ANY' do
    @c_primitive.type.should == 'ANY'
  end

  it 'default value should be assigned properly' do
    @c_primitive.default_value.value.should == 'DEFAULT'
  end

  it 'should raise ArgumentError when default_value is nil' do
    lambda {
      @c_primitive.default_value = nil
    }.should raise_error ArgumentError
  end

  it 'assumed_value should be assigned properly' do
    @c_primitive.assumed_value.value.should == 'ASSUMED'
  end

  it 'should be true when assumed_value is assigned' do
    @c_primitive.should have_assumed_value
  end

  it 'should not be true when assumed_value is not assigned' do
    @c_primitive.assumed_value = nil
    @c_primitive.should_not have_assumed_value
  end
end
