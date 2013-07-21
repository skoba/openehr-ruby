require File.dirname(__FILE__) + '/../../../../../../spec_helper'
#require File.dirname(__FILE__) + '/shared_examples_spec'
include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::DataTypes::Encapsulated
include OpenEHR::RM::DataTypes::Text

describe Activity do
#  it_should_behave_like 'entry'
  let(:name) {DvText.new(:value => 'entry package')}

  before(:each) do
    description = double(ItemStructure, :archetype_node_id => 'at0002')
    timing = double(DvParsable, :value => '2009-11-18T19:35:11')
    @activity = Activity.new(:archetype_node_id => 'at0001',
                             :name => name,
                             :description => description,
                             :timing => timing,
                             :action_archetype_id => '/at.+/')
  end

  it 'should be an instance of Activity' do
    @activity.should be_an_instance_of Activity
  end

  it 'description should be assigned properly' do
    @activity.description.archetype_node_id.should == 'at0002'
  end

  it 'should raise ArgumentError with nil description' do
    lambda {
      @activity.description = nil
    }.should raise_error ArgumentError
  end

  it 'timing should be assigned properly' do
    @activity.timing.value.should == '2009-11-18T19:35:11'
  end

  it 'should raise ArgumentError with nil timing' do
    lambda {
      @activity.timing = nil
    }.should raise_error ArgumentError
  end

  it 'action_archetype_id should be assigned properly' do
    @activity.action_archetype_id.should == '/at.+/'
  end

  it 'should raise ArgumentError with nil action_archetype_id' do
    lambda {
      @activity.action_archetype_id = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty action_archetype_id' do
    lambda {
      @activity.action_archetype_id = ''
    }.should raise_error ArgumentError
  end
end
