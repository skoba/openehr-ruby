require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::RM::DataTypes::Basic

describe CBoolean do
  before(:each) do
    default_value = DvBoolean.new(:value => true)
    @c_boolean = CBoolean.new(:default_value => true,
                              :true_valid => true,
                              :false_valid => true)
  end

  it 'should be_an_instance_of CBoolean' do
    @c_boolean.should be_an_instance_of CBoolean
  end

  it 'true_valid should be assigned properly' do
    @c_boolean.should be_true_valid
  end

  it 'false_valid should be assigned properly' do
    @c_boolean.should be_false_valid
  end

  it 'type should be DvBoolean' do
    @c_boolean.type.should == 'DvBoolean'
  end

  it 'should raise ArgumentError when both true_valid and false_valid are false' do
    lambda {
      @c_boolean.true_valid = false
      @c_boolean.false_valid = false
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError if both false_valid and true_valid  are false' do
    lambda {
      @c_boolean.false_valid = false
      @c_boolean.true_valid = false
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError if default_value is false and false_valid is false' do
    lambda {
      @c_boolean.false_valid = false
      @c_boolean.default_value = false
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError if default_value is true and true_valid is false' do
    lambda {
      @c_boolean.true_valid = false
      @c_boolean.default_value = true
    }.should raise_error ArgumentError
  end
end
