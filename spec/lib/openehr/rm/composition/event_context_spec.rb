require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Composition
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataStructures::ItemStructure

describe EventContext do
  before(:each) do
    start = DvDateTime.new(:value => '2009-11-13T20:46:57')
    setting_group = double(CodePhrase, :code_string => '225')
    setting = double(DvCodedText, :defining_code => setting_group)
    ending = DvDateTime.new(:value => '2010-10-14T09:00:00')
    participations = double(Array, :size => 5, :empty? => false)
    other_context = double(ItemStructure, :archetype_node_id => 'at0002')
    @event_context = EventContext.new(:start_time => start,
                                      :end_time => ending,
                                      :setting => setting,
                                      :participations => participations,
                                      :location => 'ehime',
                                      :other_context => other_context)
  end

  it 'should be an instance of EventContext' do
    @event_context.should be_an_instance_of EventContext
  end

  it 'start_time should be assigned properly' do
    @event_context.start_time.value.should == '2009-11-13T20:46:57'
  end

  it 'should raise ArgumentError with nil start_time' do
    expect {
      @event_context.start_time = nil
    }.to raise_error ArgumentError
  end
  
  it 'setting should be assigned properly' do
    @event_context.setting.defining_code.code_string.should == '225'
  end

  it 'should raise ArgumentError with nil setting' do
    expect {
      @event_context.setting = nil
    }.to raise_error ArgumentError
  end

  it 'should vaildate setting code with Terminology service'

  it 'end_time should be assigned properly' do
    @event_context.end_time.value.should == '2010-10-14T09:00:00'
  end

  it 'participations should be properly assigned' do
    @event_context.participations.size.should be_equal 5
  end

  it 'should raise ArgumentError with empty participations' do
    expect {
      @event_context.participations = [ ]
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil participations' do
    expect {
      @event_context.participations = nil
    }.not_to raise_error
  end

  it 'location should be assigned properly' do
    @event_context.location.should == 'ehime'
  end

  it 'should raise ArgumentError with empty location' do
    expect {
      @event_context.location = ''
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with nil location' do
    expect {
      @event_context.location = nil
    }.not_to raise_error
  end

  it 'other_context should be assigned properly' do
    @event_context.other_context.archetype_node_id.should == 'at0002'
  end
end
