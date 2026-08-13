require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::TimeSpecification
include OpenEHR::RM::DataTypes::Encapsulated
include OpenEHR::RM::DataTypes::Quantity::DateTime

def pivl(literal)
  DvParsable.new(:value => literal, :formalism => 'HL7:PIVL')
end

describe DvPeriodicTimeSpecification do
  describe 'HL7:PIVL (periodic interval)' do
    it 'parses the minimal form [phase]/(period) and derives a DvDuration period' do
      dv = DvPeriodicTimeSpecification.new(:value => pivl('[200004181100]/(7d)'))
      expect(dv.period).to be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DateTime::DvDuration
      expect(dv.period.value).to eq('P7D')
      expect(dv.calendar_alignment).to be_nil
      expect(dv.event_alignment).to be_nil
      expect(dv.institution_specified).to be false
      expect(dv.institution_specified?).to be false
    end

    it 'parses phase_high and a calendar alignment code' do
      dv = DvPeriodicTimeSpecification.new(:value => pivl('[200004181100;200004181110]/(7d)@DW'))
      expect(dv.calendar_alignment).to eq('DW')
    end

    it 'parses the institution-specified (IST) flag' do
      dv = DvPeriodicTimeSpecification.new(:value => pivl('[200004181100;200004181110]/(7d)@DW IST'))
      expect(dv.institution_specified).to be true
      expect(dv.institution_specified?).to be true
    end

    it 'the legacy calender_alignment spelling delegates to calendar_alignment' do
      dv = DvPeriodicTimeSpecification.new(:value => pivl('[200004181100]/(7d)@DW'))
      expect(dv.calender_alignment).to eq('DW')
    end

    it 'maps HL7 period units to ISO8601 duration designators' do
      {
        '8h' => 'PT8H',
        '30min' => 'PT30M',
        '2wk' => 'P2W',
        '1mo' => 'P1M',
        '1a' => 'P1Y'
      }.each do |hl7_period, iso8601|
        dv = DvPeriodicTimeSpecification.new(:value => pivl("[200004181100]/(#{hl7_period})"))
        expect(dv.period.value).to eq(iso8601)
      end
    end

    it 'raises ArgumentError when the literal does not match HL7:PIVL syntax' do
      expect {
        DvPeriodicTimeSpecification.new(:value => pivl('not a pivl'))
      }.to raise_error ArgumentError
    end

    it 'raises ArgumentError for an unknown period unit' do
      expect {
        DvPeriodicTimeSpecification.new(:value => pivl('[200004181100]/(7fortnights)'))
      }.to raise_error ArgumentError
    end

    it 'raises ArgumentError for an unknown calendar alignment code' do
      expect {
        DvPeriodicTimeSpecification.new(:value => pivl('[200004181100]/(7d)@XX'))
      }.to raise_error ArgumentError
    end
  end

  describe 'HL7:EIVL (event-related interval)' do
    def eivl(literal)
      DvParsable.new(:value => literal, :formalism => 'HL7:EIVL')
    end

    it 'parses a bare event code' do
      dv = DvPeriodicTimeSpecification.new(:value => eivl('ACM'))
      expect(dv.event_alignment).to eq('ACM')
      expect(dv.period).to be_nil
      expect(dv.calendar_alignment).to be_nil
      expect(dv.institution_specified).to be false
    end

    it 'parses an event code with a positive offset' do
      dv = DvPeriodicTimeSpecification.new(:value => eivl('ACM+10min'))
      expect(dv.event_alignment).to eq('ACM')
    end

    it 'parses an event code with a negative offset' do
      dv = DvPeriodicTimeSpecification.new(:value => eivl('HS-30min'))
      expect(dv.event_alignment).to eq('HS')
    end

    it 'raises ArgumentError for an unknown event code' do
      expect {
        DvPeriodicTimeSpecification.new(:value => eivl('ZZZ'))
      }.to raise_error ArgumentError
    end

    it 'raises ArgumentError for an unknown offset unit' do
      expect {
        DvPeriodicTimeSpecification.new(:value => eivl('ACM+10fortnights'))
      }.to raise_error ArgumentError
    end

    it 'raises ArgumentError when a PIVL-shaped literal is given HL7:EIVL formalism' do
      expect {
        DvPeriodicTimeSpecification.new(:value => eivl('[200004181100]/(7d)'))
      }.to raise_error ArgumentError
    end
  end

  it 'raises ArgumentError when a EIVL-shaped literal is given HL7:PIVL formalism' do
    expect {
      DvPeriodicTimeSpecification.new(:value => pivl('ACM'))
    }.to raise_error ArgumentError
  end

  it 'raises ArgumentError when formalism is neither HL7:PIVL nor HL7:EIVL' do
    wrong = DvParsable.new(:value => 'x', :formalism => 'HL7:GTS')
    expect {
      DvPeriodicTimeSpecification.new(:value => wrong)
    }.to raise_error ArgumentError
  end

  it 'raises ArgumentError with nil value' do
    expect {
      DvPeriodicTimeSpecification.new(:value => nil)
    }.to raise_error ArgumentError
  end
end
