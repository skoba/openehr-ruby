require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Text

describe DvOrdered do
  before(:each) do
    @dv_ordered = DvOrdered.new
  end

  it 'should be an instance of DvOrdered' do
    expect(@dv_ordered).to be_an_instance_of DvOrdered
  end

  it 'is_normal? should be false' do
    expect(@dv_ordered.is_normal?).to be_falsey
  end

  it 'should be normal' do
    normal_code = double(CodePhrase, :code_string => 'N')
    @dv_ordered.normal_status = normal_code
    expect(@dv_ordered.is_normal?).to be_truthy
  end

  it 'should not be normal' do
    abnormal_code = double(CodePhrase, :code_string => 'H')
    @dv_ordered.normal_status = abnormal_code
    expect(@dv_ordered.is_normal?).not_to be_truthy
  end

  it 'is_simple? should be true' do
    expect(@dv_ordered.is_simple?).to be_truthy
  end

  it 'is_simple? should be false' do
    @dv_ordered.other_reference_ranges = 'dummy'
    expect(@dv_ordered.is_simple?).to be_falsey
  end

  it 'should raise ArgumentError' do
    expect {
      @dv_ordered.other_reference_ranges = ''
    }.to raise_error ArgumentError
  end

  it 'should be normal in range' do
    normal_range = double(DvInterval, :has => true)
    @dv_ordered.normal_range = normal_range
    expect(@dv_ordered.is_normal?).to be_truthy
  end

  it 'is_strictly_comparable_to should be true for DvOrdered' do
    expect(@dv_ordered.is_strictly_comparable_to?(DvOrdered.new)).to be_truthy
  end

  it 'should be raise NotImplemented error' do
   expect {
      @dv_ordered<=>1
    }.to raise_error(NotImplementedError)
  end
end
