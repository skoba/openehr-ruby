require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe ArchetypeSlot do
  before(:each) do
    occurrences = Interval.new(:lower => 0, :upper => 1)
    includes = double(Set, :empty? => false, :size => 2)
    excludes = double(Set, :empty? => false, :size => 10)
    @archetype_slot = ArchetypeSlot.new(:path => '/event/[at0001]/',
                                        :rm_type_name => 'DV_TIME',
                                        :node_id => 'ac0001',
                                        :occurrences => occurrences,
                                        :includes => includes,
                                        :excludes => excludes)
  end

  it 'should be an instance of ArchetypeSlot' do
    expect(@archetype_slot).to be_an_instance_of ArchetypeSlot
  end

  it 'includes should be assigned properly' do
    expect(@archetype_slot.includes.size).to be_equal 2
  end

  it 'should raise ArgumentError when includes are empty' do
    expect {
      @archetype_slot.includes = Set.new
    }.to raise_error ArgumentError
  end

  it 'excludes should be assigned properly' do
    expect(@archetype_slot.excludes.size).to be_equal 10
  end

  it 'should raise ArgumentError when excludes are empty' do
    expect {
      @archetype_slot.excludes = Set.new
    }.to raise_error ArgumentError
  end

  it 'any_allowed should be false when includes and excludes are not nil' do
    expect(@archetype_slot).not_to be_any_allowed
  end

  it 'any_allowed should be false when includes are nil and excludes are not nil' do
    @archetype_slot.includes = nil
    expect(@archetype_slot).not_to be_any_allowed
  end

  it 'any_allowed should be false when includes are not nil and excludes are nil' do
    @archetype_slot.excludes = nil
    expect(@archetype_slot).not_to be_any_allowed
  end

  it 'any_allowed should be true when includes and excludes are nil' do
    @archetype_slot.includes = nil
    @archetype_slot.excludes = nil
    expect(@archetype_slot).to be_any_allowed
  end
end
