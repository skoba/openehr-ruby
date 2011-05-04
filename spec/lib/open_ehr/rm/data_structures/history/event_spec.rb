require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataStructures::History
include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe Event do
  before(:each) do
    time = DvDateTime.new(:value => '2009-11-12T10:19:33')
    state = stub(ItemStructure, :archetype_node_id => 'at0002')
    origin = DvDateTime.new(:value => '2009-11-11T10:20:40')
    parent = stub(History, :origin => origin)
    @event = Event.new(:archetype_node_id => 'at0001',
                       :name => DvText.new(:value => 'Event test'),
                       :time => time,
                       :data => 'data',
                       :state => state,
                       :parent => parent)
  end

  it 'should be an instance of Event' do
    @event.should be_an_instance_of Event
  end

  it 'data should be assigned properly' do
    @event.data.should == 'data'
  end

  it 'time should be assigned properly' do
    @event.time.value.should == '2009-11-12T10:19:33'
  end

  it 'state should be assigned properly' do
    @event.state.archetype_node_id.should == 'at0002'
  end

  it 'parent should be properly assigned' do
    @event.parent.origin.value.should == '2009-11-11T10:20:40'
  end

  it 'offset should be diff of parent.origin from time' do
    @event.offset.value.should == 'P0Y0M0W0DT23H58M53S'
  end
end
