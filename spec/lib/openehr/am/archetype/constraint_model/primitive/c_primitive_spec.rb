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
    expect(@c_primitive).to be_an_instance_of CPrimitive
  end

  it 'type is ANY' do
    expect(@c_primitive.type).to eq('ANY')
  end

  it 'default value should be assigned properly' do
    expect(@c_primitive.default_value.value).to eq('DEFAULT')
  end

  it 'assumed_value should be assigned properly' do
    expect(@c_primitive.assumed_value.value).to eq('ASSUMED')
  end

  it 'should be true when assumed_value is assigned' do
    expect(@c_primitive).to have_assumed_value
  end

  it 'should not be true when assumed_value is not assigned' do
    @c_primitive.assumed_value = nil
    expect(@c_primitive).not_to have_assumed_value
  end

  it 'type should not empty' do
    expect {@c_primitive.type = ''}.to raise_error
  end
end
