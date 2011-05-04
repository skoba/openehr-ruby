require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CDefinedObject do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    parent = stub(CAttribute, :rm_attribute_name => 'DV_DATE')
    @c_defined_object = CDefinedObject.new(:path => '/event/[at0001]/',
                                           :rm_type_name => 'DV_TIME',
                                           :node_id => 'ac0001',
                                           :occurrences => occurrences,
                                           :assumed_value => 'ANY')
  end

  it 'should be an instance of CDefinedObject' do
    @c_defined_object.should be_an_instance_of CDefinedObject
  end

  it 'should be assigned properly' do
    @c_defined_object.assumed_value.should == 'ANY'
  end

  it 'has_assumed_value should be true' do
    @c_defined_object.should have_assumed_value
  end

  it 'has_assumed_value should not be true' do
    @c_defined_object.assumed_value = nil
    @c_defined_object.should_not have_assumed_value
  end

  it 'default_value should raise NotImplementedError' do
    lambda {
      @c_defined_object.default_value
    }.should raise_error NotImplementedError
  end

  it 'valid_value should raise NotImplementedError' do
    lambda {
      @c_defined_object.valid_value?(1)
    }.should raise_error NotImplementedError
  end

  it 'any_allowed should raise NotImplementedError' do
    lambda {
      @c_defined_object.any_allowed?
    }.should raise_error NotImplementedError
  end
end



