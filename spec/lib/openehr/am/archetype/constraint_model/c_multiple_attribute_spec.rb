require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CMultipleAttribute do
  before(:each) do
    existence = Interval.new(:upper =>0, :lower => 0) 
    cardinality = double(Cardinality, :ordered? => true)
    @c_multiple_attribute =
      CMultipleAttribute.new(:path => '/event/at001',
                             :rm_attribute_name => 'DV_DATE',
                             :existence => existence,
                             :cardinality => cardinality)
  end

  it 'should be an instance of CMulitipleAttribute' do
    @c_multiple_attribute.should be_an_instance_of CMultipleAttribute
  end

  it 'cardinality should be assigned properly' do
    @c_multiple_attribute.cardinality.should be_ordered
  end
end
