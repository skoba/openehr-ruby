require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe ConstraintRef do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    @constraint_ref =
      ConstraintRef.new(:path => '/event/[at0001]/',
                        :rm_type_name => 'DV_TIME',
                        :node_id => 'ac0001',
                        :occurrences => occurrences,
                        :reference => 'ac0002')
  end

  it 'should be an instance of ConstraintRef' do
    expect(@constraint_ref).to be_an_instance_of ConstraintRef
  end

  it 'reference should be assigned properly' do
    expect(@constraint_ref.reference).to eq('ac0002')
  end

  it 'should raise ArgumentError when reference is nil' do
    expect {
      @constraint_ref.reference = nil
    }.to raise_error ArgumentError
  end
end
