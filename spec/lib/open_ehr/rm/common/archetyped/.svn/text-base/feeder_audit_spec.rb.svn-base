require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Archetyped
include OpenEHR::RM::DataTypes::Encapsulated
include OpenEHR::RM::DataTypes::Basic

describe FeederAudit do
  before(:each) do
    originating_system_audit = stub(FeederAuditDetails, :system_id => 'CASPAR')
    originating_system_item_ids = stub(Array, :size => 10)
    feeder_system_audit = stub(FeederAuditDetails, :system_id => 'BARTHASAR')
    feeder_system_item_ids = stub(Array, :size => 5)
    original_content = stub(DvEncapsulated, :charset => 'UTF-8')
    @feeder_audit = FeederAudit.new(
       :originating_system_audit => originating_system_audit,
       :originating_system_item_ids => originating_system_item_ids,
       :feeder_system_audit => feeder_system_audit,
       :feeder_system_item_ids => feeder_system_item_ids,
       :original_content => original_content)
  end

  it 'should be an instance of FeederAudit' do
    @feeder_audit.should be_an_instance_of FeederAudit
  end

  it 'originating_system_audit.system_id should be CASPAR' do
    @feeder_audit.originating_system_audit.system_id.should == 'CASPAR'
  end

  it 'originating_system_item_ids.size should be equal 10' do
    @feeder_audit.originating_system_item_ids.size.should be_equal 10
  end

  it 'feeder_system_audit.system_id should BARTHASAR' do
    @feeder_audit.feeder_system_audit.system_id.should == 'BARTHASAR'
  end

  it 'feeder_system_item_ids.size should be equal 5' do
    @feeder_audit.feeder_system_item_ids.size.should be_equal 5
  end

  it 'original_content.charset should be UTF-8' do
    @feeder_audit.original_content.charset.should == 'UTF-8'
  end

  it 'should raise ArgumentError with nil originating_system_audit' do
    lambda {
      @feeder_audit.originating_system_audit = nil
    }.should raise_error ArgumentError
  end
end

