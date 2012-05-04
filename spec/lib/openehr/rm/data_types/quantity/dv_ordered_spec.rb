require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Text

describe DvOrdered do
  before(:each) do
    @dv_ordered = DvOrdered.new
  end

  it 'should be an instance of DvOrdered' do
    @dv_ordered.should be_an_instance_of DvOrdered
  end

  it 'is_normal? should be false' do
    @dv_ordered.is_normal?.should be_false
  end

  it 'should be normal' do
    normal_code = stub(CodePhrase, :code_string => 'N')
    @dv_ordered.normal_status = normal_code
    @dv_ordered.is_normal?.should be_true
  end

  it 'should not be normal' do
    abnormal_code = stub(CodePhrase, :code_string => 'H')
    @dv_ordered.normal_status = abnormal_code
    @dv_ordered.is_normal?.should_not be_true
  end

  it 'is_simple? should be true' do
    @dv_ordered.is_simple?.should be_true
  end

  it 'is_simple? should be false' do
    @dv_ordered.other_reference_ranges = 'dummy'
    @dv_ordered.is_simple?.should be_false
  end

  it 'should raise ArgumentError' do
    lambda{
      @dv_ordered.other_reference_ranges = ''
    }.should raise_error ArgumentError
  end

  it 'should be normal in range' do
    normal_range = stub(DvInterval, :has => true)
    @dv_ordered.normal_range = normal_range
    @dv_ordered.is_normal?.should be_true
  end

  it 'is_strictly_comparable_to should be true for DvOrdered' do
    @dv_ordered.is_strictly_comparable_to?(DvOrdered.new).should be_true
  end

  it 'should be raise NotImplemented error' do
    lambda {
      @dv_ordered<=>1
    }.should raise_error(NotImplementedError)
  end
end
