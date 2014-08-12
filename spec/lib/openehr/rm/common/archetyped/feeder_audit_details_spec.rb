require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Archetyped
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe FeederAuditDetails do
  before(:each) do
    provider = double(PartyIdentified, :name => 'NERV')
    location = double(PartyIdentified, :name => '3rd Tokyo')
    time = double(DvDateTime, :value => '2009-09-28T19:40')
    subject = double(PartyProxy, :type => 'PARTY')
    @feeder_audit_details =
      FeederAuditDetails.new(:system_id => 'MELCHIOR',
                             :provider => provider,
                             :location => location,
                             :time => time,
                             :subject => subject,
                             :version_id => '0.5.0')
  end

  it 'should be an instance of FeederAuditDetails' do
    expect(@feeder_audit_details).to be_an_instance_of FeederAuditDetails
  end

  it 'system_id should be MELCHIOR' do
    expect(@feeder_audit_details.system_id).to eq('MELCHIOR')
  end

  it 'provider.name should be NERV' do
    expect(@feeder_audit_details.provider.name).to eq('NERV')
  end

  it 'location.name should be 3rd Tokyo' do
    expect(@feeder_audit_details.location.name).to eq('3rd Tokyo')
  end

  it 'time.value should be 2009-09-28T19:40' do
    expect(@feeder_audit_details.time.value).to eq('2009-09-28T19:40')
  end

  it 'subject.type should be PARTY' do
    expect(@feeder_audit_details.subject.type).to eq('PARTY')
  end

  it 'version_id should be 0.5.0' do
    expect(@feeder_audit_details.version_id).to eq('0.5.0')
  end

  it 'should reise ArgumentError with nil system_id' do
    expect {
      @feeder_audit_details.system_id = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty syste_id' do
    expect {
      @feeder_audit_details.system_id = ''
    }.to raise_error ArgumentError
  end
end
