require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CReferenceObject do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    @c_reference_object = CReferenceObject.new(:path => '/event/[at0001]/',
                                               :rm_type_name => 'DV_TIME',
                                               :node_id => 'ac0001',
                                               :occurrences => occurrences)
  end

  it 'should be an instance of CReferenceObject' do
    expect(@c_reference_object).to be_an_instance_of CReferenceObject
  end
end
