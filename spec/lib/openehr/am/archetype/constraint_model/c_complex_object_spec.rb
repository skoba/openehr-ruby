require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CComplexObject do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    parent = stub(CAttribute, :rm_attribute_name => 'DV_DATE')
    attributes = stub(Set, :empty? => false, :size => 3)
    @c_complex_object = CComplexObject.new(:path => '/event/[at0001]/',
                                           :rm_type_name => 'DV_TIME',
                                           :node_id => 'ac0001',
                                           :occurrences => occurrences,
                                           :attributes => attributes)
  end

  it 'should be an instance of CComplexObject' do
    @c_complex_object.should be_an_instance_of CComplexObject
  end

  it 'attributes should be assigned properly' do
    @c_complex_object.attributes.size.should be_equal 3
  end

  it 'any_allowed should be false when attributes are not empty' do
    @c_complex_object.should_not be_any_allowed
  end


  it 'any_allowed should be true when attributes are nil' do
    @c_complex_object.attributes = nil
    @c_complex_object.should be_any_allowed
  end

  it 'any_allowed should be true when attributes are empty' do
    @c_complex_object.attributes = Set.new
    @c_complex_object.should be_any_allowed
  end
end
