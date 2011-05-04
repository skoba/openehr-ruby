require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe RevisionHistory do
  before(:each) do
    version_id = stub(ObjectVersionID, :value => 'ABCD::EFGH::1')
    committed_time = stub(DvDateTime, :value => '2009-11-02T22:19:34')
    audit = stub(AuditDetails, :time_committed => committed_time)
    audits = stub(Array, :first => audit)
    last_item = stub(RevisionHistoryItem, :version_id => version_id,
                     :audits => audits)
    items = stub(Array, :size => 128, :empty? => false, :last => last_item)
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
    lambda {
      @revision_history.items = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when item is empty' do
    lambda {
      @revision_history.items = Array.new
    }.should raise_error ArgumentError
  end
end
