require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::EHR
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataStructures::ItemStructure

describe EHRStatus do
  before(:each) do
    external_ref = stub(PartyRef, :namespace => 'ehr status')
    subject = PartySelf.new(:external_ref => external_ref)
    other_details = stub(ItemStructure, :archetype_node_id => 'at0005')
    @ehr_status = EHRStatus.new(:archetype_node_id => 'at0001',
                                :name => DvText.new(:value => 'ehrstatus'),
                                :subject => subject,
                                :is_queryable => false,
                                :is_modifiable => true,
                                :other_details => other_details)
  end

  it 'should be an instance of EHRStatus' do
    @ehr_status.should be_an_instance_of EHRStatus
  end

  it 'subject should be assigned properly' do
    @ehr_status.subject.external_ref.namespace.should == 'ehr status'
  end

  it 'should raise ArgumentError with nil subject' do
    lambda {
      @ehr_status.subject = nil
    }.should raise_error ArgumentError
  end

  it 'is_queryable should be properly assigned' do
    @ehr_status.is_queryable?.should be_false
  end

  it 'is_modifiable should be assigned properly' do
    @ehr_status.is_modifiable?.should be_true
  end

  it 'other_details should be assigned properly' do
    @ehr_status.other_details.archetype_node_id.should == 'at0005'
  end

  it 'should raise ArgumentError when parant is not nil' do
    lambda {
      @ehr_status.parent = 'parent'
    }.should raise_error ArgumentError
  end
end
