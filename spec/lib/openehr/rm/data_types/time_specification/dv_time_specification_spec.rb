require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::TimeSpecification
include OpenEHR::RM::DataTypes::Encapsulated

describe DvTimeSpecification do
  before(:each) do
    @parsable = DvParsable.new(:value => 'dummy', :formalism => 'plain/text')
    @dv_time_specification = DvTimeSpecification.new(:value => @parsable)
  end

  it 'should be an instance of DvTimeSpecification' do
    expect(@dv_time_specification).to be_an_instance_of DvTimeSpecification
  end

  it 'value should be the DV_PARSABLE passed in' do
    expect(@dv_time_specification.value).to equal(@parsable)
  end

  it 'should raise ArgumentError with nil value' do
    expect {
      DvTimeSpecification.new(:value => nil)
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when value is not a DV_PARSABLE' do
    expect {
      DvTimeSpecification.new(:value => 'dummy')
    }.to raise_error ArgumentError
  end

  it 'calendar_alignment should raise NotImplementedError' do
    expect {
      @dv_time_specification.calendar_alignment
    }.to raise_error NotImplementedError
  end

  it 'calender_alignment (legacy spelling) should still work as an alias' do
    expect {
      @dv_time_specification.calender_alignment
    }.to raise_error NotImplementedError
  end

  it 'event_alignment should raise NotImplementedError' do
    expect {
      @dv_time_specification.event_alignment
    }.to raise_error NotImplementedError
  end

  it 'institution_specified should raise NotImplementedError' do
    expect {
      @dv_time_specification.institution_specified
    }.to raise_error NotImplementedError
  end
end
