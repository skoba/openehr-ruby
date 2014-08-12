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
    expect(@ehr).to be_an_instance_of EHR
  end

  it 'system_id should be assigned properly' do
    expect(@ehr.system_id.value).to eq('ABC::DEF')
  end

  it 'should raise ArgumentError with nil system_id' do
    expect {
      @ehr.system_id = nil
    }.to raise_error ArgumentError
  end

  it 'ehr_id should be assigned properly' do
    expect(@ehr.ehr_id.value).to eq('GHI::JKL')
  end

  it 'should raise ArgumentError with nil ehr_id' do
    expect {
      @ehr.ehr_id = nil
    }.to raise_error ArgumentError
  end

  it 'time_created should be assigned properly' do
    expect(@ehr.time_created.value).to eq('2009-11-14T19:01:11')
  end

  it 'should raise ArgumentError with nil time_created' do
    expect {
      @ehr.time_created = nil
    }.to raise_error ArgumentError
  end

  it 'contributions should properly assigned' do
    expect(@ehr.contributions.size).to be_equal 2
  end

  it 'type contributions should be CONTRIBUTION' do
    contributions = [double(ObjectRef, :type => 'PARTY')]
    expect {
      @ehr.contributions = contributions
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil contributions' do
    expect {
      @ehr.contributions = nil
    }.to raise_error ArgumentError
  end

  it 'ehr_access should be assigned properly' do
    expect(@ehr.ehr_access.type).to eq('VERSIONED_EHR_ACCESS')
  end

  it 'should raise ArgumentError with nil ehr_access' do
    expect {
      @ehr.ehr_access = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArguemntError with invalid ehr_access type' do
    expect {
      @ehr.ehr_access = double(ObjectRef, :type => 'VERSIONED_EHR_STATUS')
    }.to raise_error ArgumentError
  end
    
  it 'ehr_status should be assigned properly' do
    expect(@ehr.ehr_status.type).to eq('VERSIONED_EHR_STATUS')
  end

  it 'should raise ArgumentError with nil ehr_status' do
    expect {
      @ehr.ehr_status = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with invalid ehr_statsu type' do
    expect {
      @ehr.ehr_status = double(ObjectRef, :type => 'VERSIONED_EHR_ACCESS')
    }.to raise_error ArgumentError
  end

  it 'should assigned compositions properly' do
    expect(@ehr.compositions.size).to be_equal 3
  end

  it 'should raise ArgumentError with nil compositions' do
    expect {
      @ehr.compositions = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with invalid type composition' do
    expect {
      @ehr.compositions = [double(ObjectRef, :type => 'INVALID_COMPOSITION')]
    }.to raise_error ArgumentError
  end

  it 'should assigned directory properly' do
    expect(@ehr.directory.type).to eq('VERSIONED_FOLDER')
  end

  it 'should raise ArgumentError with invalid type' do
    expect {
      @ehr.directory = double(ObjectRef, :type => 'INVALID_FOLDER')
    }.to raise_error ArgumentError
  end
end
