require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe ArchetypeInternalRef do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    @archetype_internal_ref =
      ArchetypeInternalRef.new(:path => '/event/[at0001]/',
                               :rm_type_name => 'DV_TIME',
                               :node_id => 'ac0001',
                               :occurrences => occurrences,
                               :target_path => '/data/[at0002]')
  end

  it 'should be an instance of ArchetypeInternalRef' do
    expect(@archetype_internal_ref).to be_an_instance_of ArchetypeInternalRef
  end

  it 'target_path should be assigned properly' do
    expect(@archetype_internal_ref.target_path).to eq('/data/[at0002]')
  end

  it 'should raise ArgumentError when target_path is nil.' do
    expect {
      @archetype_internal_ref.target_path = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when target_path is empty.' do
    expect {
      @archetype_internal_ref.target_path = ''
    }.to raise_error ArgumentError
  end
end
  
