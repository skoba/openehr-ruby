require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataStructures::History
include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe IntervalEvent do
  before(:each) do
    time = DvDateTime.new(:value => '2009-11-12T10:19:33Z')
    math_function = double(DvCodedText, :value => 'mean')
    width = DvDuration.new(:value => 'P0Y2M1W3DT5H7M3S')
    @interval_event = IntervalEvent.new(:archetype_node_id => 'at0001',
                                :name => DvText.new(:value => 'Event test'),
                                :time => time,
                                :data => 'data',
                                :width => width,
                                :math_function => math_function, 
                                :sample_count => 1234)
  end

  it 'should be an instance of IntervalEvent' do
    @interval_event.should be_an_instance_of IntervalEvent
  end

  it 'width should be assigned properly' do
    @interval_event.width.value.should == 'P0Y2M1W3DT5H7M3S'
  end

  it 'math_function should be assigned properly' do
    @interval_event.math_function.value.should == 'mean'
  end

  it 'sample_count should be assigned properly' do
    @interval_event.sample_count.should be_equal 1234
  end

  it 'should subtract time for interval start time' do
    @interval_event.interval_start_time.value.should == '2009-09-09T05:12:30Z'
  end
end
