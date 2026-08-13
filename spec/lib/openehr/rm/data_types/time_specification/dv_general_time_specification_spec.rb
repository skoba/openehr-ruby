require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::TimeSpecification
include OpenEHR::RM::DataTypes::Encapsulated

describe DvGeneralTimeSpecification do
  before(:each) do
    @parsable = DvParsable.new(:value => 'some GTS literal', :formalism => 'HL7:GTS')
    @dv_general = DvGeneralTimeSpecification.new(:value => @parsable)
  end

  it 'should be an instance of DvGeneralTimeSpecification' do
    expect(@dv_general).to be_an_instance_of DvGeneralTimeSpecification
  end

  it 'value should be the DV_PARSABLE passed in' do
    expect(@dv_general.value).to equal(@parsable)
  end

  it 'should raise ArgumentError when formalism is not HL7:GTS' do
    wrong_formalism = DvParsable.new(:value => 'x', :formalism => 'plain/text')
    expect {
      DvGeneralTimeSpecification.new(:value => wrong_formalism)
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil value' do
    expect {
      DvGeneralTimeSpecification.new(:value => nil)
    }.to raise_error ArgumentError
  end

  it 'calendar_alignment should raise NotImplementedError (full GTS set-algebra is out of scope)' do
    expect {
      @dv_general.calendar_alignment
    }.to raise_error NotImplementedError
  end

  it 'calender_alignment (legacy spelling) should still raise NotImplementedError' do
    expect {
      @dv_general.calender_alignment
    }.to raise_error NotImplementedError
  end

  it 'event_alignment should raise NotImplementedError' do
    expect {
      @dv_general.event_alignment
    }.to raise_error NotImplementedError
  end

  it 'institution_specified should raise NotImplementedError' do
    expect {
      @dv_general.institution_specified
    }.to raise_error NotImplementedError
  end
end
