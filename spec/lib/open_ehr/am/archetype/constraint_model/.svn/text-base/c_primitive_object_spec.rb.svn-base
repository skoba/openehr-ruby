require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::ConstraintModel::Primitive
include OpenEHR::AssumedLibraryTypes

describe CPrimitiveObject do
  before(:each) do
    interval = Interval.new(:lower => 0, :upper => 1)
    item = stub(CPrimitive, :node_id => 'at0001')
    @c_primitive_object = CPrimitiveObject.new(:path => 'event/test',
                                               :rm_type_name => 'DV_TEXT',
                                               :node_id => 'ac0001',
                                               :occurrences => interval,
                                               :item => item)
  end

  it 'should be an instance of CPrimitiveObject' do
    @c_primitive_object.should be_an_instance_of CPrimitiveObject
  end

  it 'item should be assigned properly' do
    @c_primitive_object.item.node_id.should == 'at0001'
  end

  it 'should allowed any' do
    @c_primitive_object.should_not be_any_allowed
  end

  it 'should not any allowed' do
    @c_primitive_object.item = nil
    @c_primitive_object.should be_any_allowed
  end
end
