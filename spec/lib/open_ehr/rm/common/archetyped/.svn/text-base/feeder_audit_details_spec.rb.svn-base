require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Archetyped
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe FeederAuditDetails do
  before(:each) do
    provider = stub(PartyIdentified, :name => 'NERV')
    location = stub(PartyIdentified, :name => '3rd Tokyo')
    time = stub(DvDateTime, :value => '2009-09-28T19:40')
    subject = stub(PartyProxy, :type => 'PARTY')
    @feeder_audit_details =
      FeederAuditDetails.new(:system_id => 'MELCHIOR',
                             :provider => provider,
                             :location => location,
                             :time => time,
                             :subject => subject,
                             :version_id => '0.5.0')
  end

  it 'should be an instance of FeederAuditDetails' do
    @feeder_audit_details.should be_an_instance_of FeederAuditDetails
  end

  it 'system_id should be MELCHIOR' do
    @feeder_audit_details.system_id.should == 'MELCHIOR'
  end

  it 'provider.name should be NERV' do
    @feeder_audit_details.provider.name.should == 'NERV'
  end

  it 'location.name should be 3rd Tokyo' do
    @feeder_audit_details.location.name.should == '3rd Tokyo'
  end

  it 'time.value should be 2009-09-28T19:40' do
    @feeder_audit_details.time.value.should == '2009-09-28T19:40'
  end

  it 'subject.type should be PARTY' do
    @feeder_audit_details.subject.type.should == 'PARTY'
  end

  it 'version_id should be 0.5.0' do
    @feeder_audit_details.version_id.should == '0.5.0'
  end

  it 'should reise ArgumentError with nil system_id' do
    lambda {
      @feeder_audit_details.system_id = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty syste_id' do
    lambda {
      @feeder_audit_details.system_id = ''
    }.should raise_error ArgumentError
  end
end
