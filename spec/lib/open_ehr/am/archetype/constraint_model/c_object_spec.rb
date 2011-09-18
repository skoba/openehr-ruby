require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CObject do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    parent = stub(CAttribute, :rm_attribute_name => 'DV_DATE')
    @c_object = CObject.new(:path => '/event/[at0001]/',
                            :rm_type_name => 'DV_TIME',
                            :node_id => 'ac0001',
                            :occurrences => occurrences,
                            :parent => parent)
  end

  it 'should be an instance of CObject' do
    @c_object.should be_an_instance_of CObject
  end

  it 'rm_type_name should be assigned properly' do
    @c_object.rm_type_name.should == 'DV_TIME'
  end

  it 'should raise ArgumentError when rm_type_name was assigned nil' do
    lambda {
      @c_object.rm_type_name = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when rm_type_name was assigned empty' do
    lambda {
      @c_object.rm_type_name = ''
    }.should raise_error ArgumentError
  end

  it 'node_id should be assigned properly' do
    @c_object.node_id.should == 'ac0001'
  end

  it 'should raise ArgumentError when node_id was assigned nil' do
    lambda {
      @c_object.node_id = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when node_id was assigned empty' do
    lambda {
      @c_object.node_id = ''
    }.should raise_error ArgumentError
  end

  it 'occurences should be assigned properly' do
    @c_object.occurrences.lower.should be_equal 0
  end

  # it 'should raise ArgumentError when occurences was assigned nil' do
  #   lambda {
  #     @c_object.occurrences = nil
  #   }.should raise_error ArgumentError
  # end
end
