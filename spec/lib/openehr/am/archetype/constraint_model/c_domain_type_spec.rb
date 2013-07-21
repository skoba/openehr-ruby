require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe CDomainType do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    @c_domain_type = CDomainType.new(:path => '/event/[at0001]/',
                                     :rm_type_name => 'DV_TIME',
                                     :node_id => 'ac0001',
                                     :occurrences => occurrences)
  end

  it 'should be an instance of CDomainType' do
    @c_domain_type.should be_an_instance_of CDomainType
  end

  it 'standard_equivalent should raise NotImplementedError' do
    expect {
      @c_domain_type.standard_equivalent
    }.to raise_error NotImplementedError
  end
end
                                           
