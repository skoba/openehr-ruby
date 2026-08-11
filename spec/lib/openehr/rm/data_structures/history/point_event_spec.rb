require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataStructures::History
include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe PointEvent do
  before(:each) do
    time = DvDateTime.new(:value => '2009-11-12T10:19:33')
    state = double(ItemStructure, :archetype_node_id => 'at0002')
    @point_event = PointEvent.new(:archetype_node_id => 'at0001',
                                  :name => DvText.new(:value => 'Point event test'),
                                  :time => time,
                                  :data => 'data',
                                  :state => state)
  end

  it 'should be an instance of PointEvent' do
    expect(@point_event).to be_an_instance_of PointEvent
  end

  it 'should be a kind of Event' do
    expect(@point_event).to be_a Event
  end

  it 'data should be assigned properly' do
    expect(@point_event.data).to eq('data')
  end

  it 'should raise ArgumentError when nil assigned to data' do
    expect {
      @point_event.data = nil
    }.to raise_error ArgumentError
  end

  it 'time should be assigned properly' do
    expect(@point_event.time.value).to eq('2009-11-12T10:19:33')
  end

  it 'should raise ArgumentError when nil assigned to time' do
    expect {
      @point_event.time = nil
    }.to raise_error ArgumentError
  end

  it 'state should be assigned properly' do
    expect(@point_event.state.archetype_node_id).to eq('at0002')
  end

  it 'offset should be diff of parent.origin from time when auto-wired via History#events=' do
    origin = DvDateTime.new(:value => '2009-11-11T10:20:40')
    OpenEHR::RM::DataStructures::History::History.new(
      :archetype_node_id => 'at0003',
      :name => DvText.new(:value => 'history'),
      :origin => origin,
      :events => [@point_event])
    expect(@point_event.offset.value).to eq('P0Y0M0W0DT23H58M53S')
  end
end
