require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Basic


describe DvBoolean do
  before(:each) do
    @dv_boolean = DvBoolean.new(:value => "TRUE")
  end

  it 'should be an instance of DvBoolean' do
    expect(@dv_boolean).to be_an_instance_of DvBoolean
  end

  it 'should be true' do
    expect(@dv_boolean.value).to be_truthy
    expect(@dv_boolean.value?).to be_truthy
  end

  it 's value assigned false, then it should not be false' do
    @dv_boolean.value = false
    expect(@dv_boolean.value).not_to be_truthy
  end

  it 'raise ArgumentError' do
    expect {
      @dv_boolean.value = nil
    }.to raise_error(ArgumentError)
  end
end
