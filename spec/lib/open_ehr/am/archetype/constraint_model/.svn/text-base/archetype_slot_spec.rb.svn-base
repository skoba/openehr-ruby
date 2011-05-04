require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe ArchetypeSlot do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    includes = stub(Set, :empty? => false, :size => 2)
    excludes = stub(Set, :empty? => false, :size => 10)
    @archetype_slot = ArchetypeSlot.new(:path => '/event/[at0001]/',
                                        :rm_type_name => 'DV_TIME',
                                        :node_id => 'ac0001',
                                        :occurrences => occurrences,
                                        :includes => includes,
                                        :excludes => excludes)
  end

  it 'should be an instance of ArchetypeSlot' do
    @archetype_slot.should be_an_instance_of ArchetypeSlot
  end

  it 'includes should be assigned properly' do
    @archetype_slot.includes.size.should be_equal 2
  end

  it 'should raise ArgumentError when includes are empty' do
    lambda {
      @archetype_slot.includes = Set.new
    }.should raise_error ArgumentError
  end

  it 'excludes should be assigned properly' do
    @archetype_slot.excludes.size.should be_equal 10
  end

  it 'should raise ArgumentError when excludes are empty' do
    lambda {
      @archetype_slot.excludes = Set.new
    }.should raise_error ArgumentError
  end

  it 'any_allowed should be false when includes and excludes are not nil' do
    @archetype_slot.should_not be_any_allowed
  end

  it 'any_allowed should be false when includes are nil and excludes are not nil' do
    @archetype_slot.includes = nil
    @archetype_slot.should_not be_any_allowed
  end

  it 'any_allowed should be false when includes are not nil and excludes are nil' do
    @archetype_slot.excludes = nil
    @archetype_slot.should_not be_any_allowed
  end

  it 'any_allowed should be true when includes and excludes are nil' do
    @archetype_slot.includes = nil
    @archetype_slot.excludes = nil
    @archetype_slot.should be_any_allowed
  end
end
