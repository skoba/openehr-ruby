require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::Support::Identification

describe RevisionHistoryItem do
  before(:each)do
    version_id = stub(ObjectVersionID, :objectid => 'RIO')
    audits = stub(Array, :size => 30, :empty? => false)
    @revision_history_item =
      RevisionHistoryItem.new(:version_id => version_id,
                              :audits => audits)
  end

  it 'should be an instance of RevisionHistoryItem' do
    @revision_history_item.should be_an_instance_of RevisionHistoryItem
  end

  it 's version_id.objectid should be RIO' do
    @revision_history_item.version_id.objectid.should == 'RIO'
  end

  it 's audits.size should be 30' do
    @revision_history_item.audits.size.should be_equal 30
  end

  it 'should raise ArgumentError when nil is assigned to version id' do
    lambda {
      @revision_history_item.version_id = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when nil is assinged to audits' do
    lambda {
      @revision_history_item.audits = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when empty is assinged to audits' do
    lambda {
      @revision_history_item.audits = Array.new
    }.should raise_error ArgumentError
  end
end
