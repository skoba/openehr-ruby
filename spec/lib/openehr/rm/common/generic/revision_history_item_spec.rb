require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::Support::Identification

describe RevisionHistoryItem do
  before(:each)do
    version_id = double(ObjectVersionID, :objectid => 'RIO')
    audits = double(Array, :size => 30, :empty? => false)
    @revision_history_item =
      RevisionHistoryItem.new(:version_id => version_id,
                              :audits => audits)
  end

  it 'should be an instance of RevisionHistoryItem' do
    expect(@revision_history_item).to be_an_instance_of RevisionHistoryItem
  end

  it 's version_id.objectid should be RIO' do
    expect(@revision_history_item.version_id.objectid).to eq('RIO')
  end

  it 's audits.size should be 30' do
    expect(@revision_history_item.audits.size).to be_equal 30
  end

  it 'should raise ArgumentError when nil is assigned to version id' do
    expect {
      @revision_history_item.version_id = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when nil is assinged to audits' do
    expect {
      @revision_history_item.audits = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when empty is assinged to audits' do
    expect {
      @revision_history_item.audits = Array.new
    }.to raise_error ArgumentError
  end
end
