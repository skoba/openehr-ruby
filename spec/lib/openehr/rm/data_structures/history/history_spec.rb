require File.dirname(__FILE__) + '/../../../../../spec_helper'

include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe History do
  before(:each) do
    origin = DvDateTime.new(:value => '2009-11-01T00:00:00')
    period = DvDuration.new(:value => 'P1Y2M3W4D')
    duration = DvDuration.new(:value => 'P0Y0M0W6D')
    events = [double(Event, :archetype_node_id => 'at0002')]
    summary = double(ItemStructure, :archetype_node_id => 'at0003')
    @history = OpenEHR::RM::DataStructures::History::History.new(:archetype_node_id => 'at0001',
                           :name => DvText.new(:value => 'history test'),
                           :origin => origin,
                           :period => period,
                           :duration => duration,
                           :events => events,
                           :summary => summary)
  end

  it 'should be an instance of History' do
    expect(@history).to be_an_instance_of OpenEHR::RM::DataStructures::History::History
  end

  it 'origin should be properly assigned' do
    expect(@history.origin.value).to eq('2009-11-01T00:00:00')
  end

  it 'should raise ArgumentError with nil origin' do
    expect {
      @history.origin = nil
    }.to raise_error ArgumentError
  end

  it 'period should be properly assigned' do
    expect(@history.period.value).to eq('P1Y2M3W4D')
  end

  it 'duration should be properly assigned' do
    expect(@history.duration.value).to eq('P0Y0M0W6D')
  end

  it 'is_periodic? should be true when period is not nil' do
    expect(@history.is_periodic?).to be_truthy
  end

  it 'is_periodic? should be false when period is nil' do
    @history.period = nil
    expect(@history.is_periodic?).to be_falsey
  end

  it 'events should be properly assigned' do
    expect(@history.events[0].archetype_node_id).to eq('at0002')
  end

  it 'empty events should raise ArgumentError' do
    expect {
      @history.events = []
    }.to raise_error ArgumentError
  end

  it 'summary should be properly assigned' do
    expect(@history.summary.archetype_node_id).to eq('at0003')
  end
end
