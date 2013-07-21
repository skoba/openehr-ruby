require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CComplexObject do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    parent = double(CAttribute, :rm_attribute_name => 'event',
                  :path => "/event")
    attribute = CAttribute.new(:rm_attribute_name => 'data')
    attributes = [attribute, attribute, attribute]
    @c_complex_object = CComplexObject.new(:rm_type_name => 'DV_TIME',
                                           :parent => parent,
                                           :node_id => 'at0001',
                                           :occurrences => occurrences,
                                           :attributes => attributes)
  end

  it 'should be an instance of CComplexObject' do
    @c_complex_object.should be_an_instance_of CComplexObject
  end

  it 'attributes should be assigned properly' do
    @c_complex_object.attributes.size.should be_equal 3
  end

  it 'attributes parent should be assigned properly' do
    @c_complex_object.attributes[0].parent.should == @c_complex_object
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

  it 'path should be calculated properly' do
    @c_complex_object.path.should == '/event[at0001]'
  end

  context 'path' do
    before(:each) do
      @c_complex_object.path = '/event[at0002]'
    end

    it 'should be assigned properly' do
      @c_complex_object.path.should == '/event[at0002]'
    end
  end
end
