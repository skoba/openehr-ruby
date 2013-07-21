require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe AuditDetails do
  before(:each) do
    committer = double(PartyProxy, :namespace => 'UNKNOWN')
    change_type = double(DvCodedText, :value =>'creation')
    time = double(DvDateTime, :value => '2009-10-03T16:24:19.0Z')
    desc = DvText.new(:value => 'test environment')
    @audit_details = AuditDetails.new(:system_id => 'MAGI',
                                      :committer => committer,
                                      :time_committed => time,
                                      :change_type => change_type,
                                      :description => desc)
  end

  it 'should be an instance of AuditDetails' do
    @audit_details.should be_an_instance_of AuditDetails
  end

  it 'system_id should be MAGI' do
    @audit_details.system_id.should == 'MAGI'
  end

  it 'committer namespece should be UNKNOWN' do
    @audit_details.committer.namespace.should == 'UNKNOWN'
  end

  it 'change_type.value should be creation' do
    @audit_details.change_type.value.should == 'creation'
  end

  it 'description should be test environment' do
    @audit_details.description.value.should == 'test environment'
  end

  it 'should raise ArgumentError when system_id was assigned nil' do
    expect {
      @audit_details.system_id = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when time_commited is nil' do
    expect {
      @audit_details.time_committed = nil
    }.to raise_error ArgumentError
  end
end
