require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Basic


describe DvBoolean do
  before(:each) do
    @dv_boolean = DvBoolean.new(:value => "TRUE")
  end

  it 'should be an instance of DvBoolean' do
    @dv_boolean.should be_an_instance_of DvBoolean
  end

  it 'should be true' do
    @dv_boolean.value.should be_true
    @dv_boolean.value?.should be_true
  end

  it 's value assigned false, then it should not be false' do
    @dv_boolean.value = false
    @dv_boolean.value.should_not be_true
  end

  it 'raise ArgumentError' do
    lambda {
      @dv_boolean.value = nil
    }.should raise_error(ArgumentError)
  end
end
