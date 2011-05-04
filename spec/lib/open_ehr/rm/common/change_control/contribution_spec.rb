require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::ChangeControl
include OpenEHR::RM::DataTypes::Text

describe Contribution do
  before(:each) do
    uid = HierObjectID.new(:value => 'ABC::DEF::2')
    versions = stub(Set, :size => 2, :empty? => false)
    description = DvText.new(:value => 'test')
    audit = stub(AuditDetails, :empty? => false, :description => description)
    @contribution = Contribution.new(:uid => uid,
                                     :versions => versions,
                                     :audit => audit)
  end

  it 'should be an instance of Contribution' do
    @contribution.should be_an_instance_of Contribution
  end

  it 'uid.value should be ABC::DEF::2' do
    @contribution.uid.value.should == 'ABC::DEF::2'
  end

  it 'audit.description should test' do
    @contribution.audit.description.value.should == 'test'
  end

  it 'versions size should be 2' do
    @contribution.versions.size.should == 2
  end

  it 'should raise ArgumentError when version is empty' do
    lambda {
      @contribution.versions = Set.new
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when uid is nil' do
    lambda {
      @contribution.uid = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError audit is nil' do
    lambda {
      @contribution.audit = nil
    }.should raise_error ArgumentError
  end

  it 'shoudl raise ArgumentError audit.description is empty' do
    nil_audit = stub(AuditDetails, :description => nil)
    lambda {
      @contribution.audit = nil_audit
    }.should raise_error ArgumentError
  end 
end
