require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel

describe ArchetypeConstraint do
  before(:each) do
    parent = stub(ArchetypeConstraint, :path => '/data/[at0001]')
    @archetype_constraint =
      ArchetypeConstraint.new(:path => '/data/events[at0003]/data/items[at0025]/value/magnitude',
                              :parent => parent)
  end

  it 'should be an instance of ArchetypeConstraint' do
    @archetype_constraint.should be_an_instance_of ArchetypeConstraint
  end

  it 'path should be assigned properly' do
    @archetype_constraint.path.should == '/data/events[at0003]/data/items[at0025]/value/magnitude'
  end

  it 'should raise ArgumentError when path is not assigned' do
    lambda {
      @archetype_constraint.path = nil
    }.should raise_error ArgumentError
  end

  it 'has_path? should return true if it has path' do
    @archetype_constraint.should have_path 'events[at0003]'
  end

  it 'has_path? should return false if ti does not have path' do
    @archetype_constraint.should_not have_path 'events[at0004]'
  end

  it 'parent should assigned properly' do
    @archetype_constraint.parent.path.should == '/data/[at0001]'
  end

  it 'is congruent means this node starts from parent node' do
    @archetype_constraint.should_not be_congruent
  end

  it 'is congruent when path starts with parent path' do
    @archetype_constraint.path = '/data/[at0001]/test'
    @archetype_constraint.should be_congruent
  end

  it 'node_conforms_to return true if path is follower' do
    other = stub(ArchetypeConstraint, :path => '/data/events[at0003]')
    @archetype_constraint.node_conforms_to?(other).should be_true
  end

  it 'node_conforms_to return false if path is other lineage' do
    other = stub(ArchetypeConstraint, :path => '/event/')
    @archetype_constraint.node_conforms_to?(other).should be_false
  end
end
