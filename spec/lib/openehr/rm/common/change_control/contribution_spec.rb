require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::ChangeControl
include OpenEHR::RM::DataTypes::Text

describe Contribution do
  before(:each) do
    uid = HierObjectID.new(:value => 'ABC::DEF::2')
    versions = double(Set, :size => 2, :empty? => false)
    description = DvText.new(:value => 'test')
    audit = double(AuditDetails, :empty? => false, :description => description)
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
    expect {
      @contribution.versions = Set.new
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when uid is nil' do
    expect {
      @contribution.uid = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError audit is nil' do
    expect {
      @contribution.audit = nil
    }.to raise_error ArgumentError
  end

  it 'shoudl raise ArgumentError audit.description is empty' do
    nil_audit = double(AuditDetails, :description => nil)
    expect {
      @contribution.audit = nil_audit
    }.to raise_error ArgumentError
  end 
end
