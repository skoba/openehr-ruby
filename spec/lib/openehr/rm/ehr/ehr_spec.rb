require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::EHR
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe EHR do
  before(:each) do
    system_id = HierObjectID.new(:value => 'ABC::DEF')
    ehr_id = HierObjectID.new(:value => 'GHI::JKL')
    time_created = DvDateTime.new(:value => '2009-11-14T19:01:11')
    ehr_access = double(ObjectRef, :type => 'VERSIONED_EHR_ACCESS')
    ehr_status = double(ObjectRef, :type => 'VERSIONED_EHR_STATUS')
    contribution1 = double(ObjectRef, :type => 'CONTRIBUTION')
    contribution2 = double(ObjectRef, :type => 'CONTRIBUTION')
    contributions = [contribution1, contribution2]
    directory = double(ObjectRef, :type => 'VERSIONED_FOLDER')
    composition1 = double(ObjectRef, :type => 'VERSIONED_COMPOSITION')
    composition2 = double(ObjectRef, :type => 'VERSIONED_COMPOSITION')
    composition3 = double(ObjectRef, :type => 'VERSIONED_COMPOSITION')
    compositions = [composition1, composition2, composition3]
    @ehr = EHR.new(:system_id => system_id,
                   :ehr_id => ehr_id,
                   :time_created => time_created,
                   :contributions => contributions,
                   :ehr_access => ehr_access,
                   :ehr_status => ehr_status,
                   :directory => directory,
                   :compositions => compositions)
  end

  it 'should be an instance of EHR' do
    @ehr.should be_an_instance_of EHR
  end

  it 'system_id should be assigned properly' do
    @ehr.system_id.value.should == 'ABC::DEF'
  end

  it 'should raise ArgumentError with nil system_id' do
    lambda {
      @ehr.system_id = nil
    }.should raise_error ArgumentError
  end

  it 'ehr_id should be assigned properly' do
    @ehr.ehr_id.value.should == 'GHI::JKL'
  end

  it 'should raise ArgumentError with nil ehr_id' do
    lambda {
      @ehr.ehr_id = nil
    }.should raise_error ArgumentError
  end

  it 'time_created should be assigned properly' do
    @ehr.time_created.value.should == '2009-11-14T19:01:11'
  end

  it 'should raise ArgumentError with nil time_created' do
    lambda {
      @ehr.time_created = nil
    }.should raise_error ArgumentError
  end

  it 'contributions should properly assigned' do
    @ehr.contributions.size.should be_equal 2
  end

  it 'type contributions should be CONTRIBUTION' do
    contributions = [double(ObjectRef, :type => 'PARTY')]
    lambda {
      @ehr.contributions = contributions
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil contributions' do
    lambda {
      @ehr.contributions = nil
    }.should raise_error ArgumentError
  end

  it 'ehr_access should be assigned properly' do
    @ehr.ehr_access.type.should == 'VERSIONED_EHR_ACCESS'
  end

  it 'should raise ArgumentError with nil ehr_access' do
    lambda {
      @ehr.ehr_access = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArguemntError with invalid ehr_access type' do
    lambda {
      @ehr.ehr_access = double(ObjectRef, :type => 'VERSIONED_EHR_STATUS')
    }.should raise_error ArgumentError
  end
    
  it 'ehr_status should be assigned properly' do
    @ehr.ehr_status.type.should == 'VERSIONED_EHR_STATUS'
  end

  it 'should raise ArgumentError with nil ehr_status' do
    lambda {
      @ehr.ehr_status = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with invalid ehr_statsu type' do
    lambda {
      @ehr.ehr_status = double(ObjectRef, :type => 'VERSIONED_EHR_ACCESS')
    }.should raise_error ArgumentError
  end

  it 'should assigned compositions properly' do
    @ehr.compositions.size.should be_equal 3
  end

  it 'should raise ArgumentError with nil compositions' do
    lambda {
      @ehr.compositions = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with invalid type composition' do
    lambda {
      @ehr.compositions = [double(ObjectRef, :type => 'INVALID_COMPOSITION')]
    }.should raise_error ArgumentError
  end

  it 'should assigned directory properly' do
    @ehr.directory.type.should == 'VERSIONED_FOLDER'
  end

  it 'should raise ArgumentError with invalid type' do
    lambda {
      @ehr.directory = double(ObjectRef, :type => 'INVALID_FOLDER')
    }.should raise_error ArgumentError
  end
end
