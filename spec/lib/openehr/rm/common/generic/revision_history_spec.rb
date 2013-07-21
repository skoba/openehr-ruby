require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe RevisionHistory do
  before(:each) do
    version_id = double(ObjectVersionID, :value => 'ABCD::EFGH::1')
    committed_time = double(DvDateTime, :value => '2009-11-02T22:19:34')
    audit = double(AuditDetails, :time_committed => committed_time)
    audits = double(Array, :first => audit)
    last_item = double(RevisionHistoryItem, :version_id => version_id,
                     :audits => audits)
    items = double(Array, :size => 128, :empty? => false, :last => last_item)
    @revision_history = RevisionHistory.new(:items => items)
  end

  it 'should be an instance of RevisionHistory' do
    @revision_history.should be_an_instance_of RevisionHistory
  end

  it 'items size should return size 128' do
    @revision_history.items.size.should be_equal 128
  end

  it 'should return the most recent version string' do
    @revision_history.most_recent_version.should == 'ABCD::EFGH::1'
  end

  it 'should return the most recent commited version time string' do
    @revision_history.most_recent_version_time_committed == '2009-11-02T22:19:34'
  end

  it 'should raise ArgumentError when item is nil' do
    expect {
      @revision_history.items = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when item is empty' do
    expect {
      @revision_history.items = Array.new
    }.to raise_error ArgumentError
  end
end
