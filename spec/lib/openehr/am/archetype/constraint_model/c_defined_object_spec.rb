require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CDefinedObject do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    @c_defined_object = CDefinedObject.new(:path => '/event/[at0001]/',
                                           :rm_type_name => 'DV_TIME',
                                           :node_id => 'ac0001',
                                           :occurrences => occurrences,
                                           :assumed_value => 'ANY')
  end

  it 'should be an instance of CDefinedObject' do
    expect(@c_defined_object).to be_an_instance_of CDefinedObject
  end

  it 'should be assigned properly' do
    expect(@c_defined_object.assumed_value).to eq('ANY')
  end

  it 'has_assumed_value should be true' do
    expect(@c_defined_object).to have_assumed_value
  end

  it 'has_assumed_value should not be true' do
    @c_defined_object.assumed_value = nil
    expect(@c_defined_object).not_to have_assumed_value
  end

  it 'default_value should raise NotImplementedError' do
    expect {
      @c_defined_object.default_value
    }.to raise_error NotImplementedError
  end

  it 'valid_value should raise NotImplementedError' do
    expect {
      @c_defined_object.valid_value?(1)
    }.to raise_error NotImplementedError
  end

  it 'any_allowed should raise NotImplementedError' do
    expect {
      @c_defined_object.any_allowed?
    }.to raise_error NotImplementedError
  end
end



