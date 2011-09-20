require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CSingleAttribute do
  before(:each) do
    existence = Interval.new(:upper =>0, :lower => 0) 
    alternatives = stub(Array, :size => 5)
    @c_single_attribute = CSingleAttribute.new(:path => '/event/at001',
                                              :rm_attribute_name => 'DV_DATE',
                                              :existence => existence,
                                              :alternatives => alternatives)
  end

  it 'should be an instance of CSingleAttribute' do
    @c_single_attribute.should be_an_instance_of CSingleAttribute
  end

  it 'alternative should be assigned properly' do
    @c_single_attribute.alternatives.size.should be_equal 5
  end
end
