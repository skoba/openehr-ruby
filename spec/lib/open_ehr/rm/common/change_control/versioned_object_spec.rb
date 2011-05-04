require File.dirname(__FILE__) + '/../../../../../spec_helper'
#require File.dirname(__FILE__) + '/shared_examples_spec'
include OpenEHR::RM::Common::ChangeControl
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::DataTypes::Text

describe VersionedObject do
  before(:each) do
    uid1 = ObjectVersionID.new(:value => 'ABC::DEF::1')
    defining_code1 = stub(CodePhrase, :code_string => '532')
    lifecycle_state1 = stub(DvCodedText, :defining_code => defining_code1)
    time_committed1 = DvDateTime.new(:value => '2008-11-12T18:24:32')
    audit_details1 = stub(AuditDetails, :time_committed => time_committed1)
    version1 = stub(Version, :commit_audit => audit_details1,
                             :lifecycle_state => lifecycle_state1,
                             :uid => uid1)
    uid2 = ObjectVersionID.new(:value => 'GHI::JKL::2')
    defining_code2 = stub(CodePhrase, :code_string => '553')
    lifecycle_state2 = stub(DvCodedText, :defining_code => defining_code2)
    time_committed2 = DvDateTime.new(:value => '2008-12-12T19:32:14')
    audit_details2 = stub(AuditDetails, :time_committed => time_committed2)
    attestation = stub(Attestation)
    attestations = Array.new([attestation])
    contribution = stub(ObjectRef, :empty? => false, :type => 'CONTRIBUTION')
    version2 = OriginalVersion.new(:commit_audit => audit_details2,
                                   :lifecycle_state => lifecycle_state2,
                                   :preceding_version_uid => uid1,
                                   :uid => uid2,
                                   :contribution => contribution,
                                   :attestations => attestations)
    uid3 = ObjectVersionID.new(:value => 'MNO::PQR::3')
    defining_code3 = stub(CodePhrase, :code_string => '523')
    lifecycle_state3 = stub(DvCodedText, :defining_code => defining_code3)
    time_committed3 = DvDateTime.new(:value => '2009-07-15T09:24:26')
    audit_details3 = stub(AuditDetails, :time_committed => time_committed3)
    version3 = stub(Version, :commit_audit => audit_details3,
                             :lifecycle_state => lifecycle_state3,
                             :uid => uid3)
    uid = HierObjectID.new(:value => 'STU::VWX::5')
    owner_id = stub(ObjectRef, :namespace => 'test')
    time_created = DvDateTime.new(:value => '2009-11-09T09:53:22')
    object_id = stub(ObjectID, :value => 'unique')
    all_versions = [version1, version2, version3]
    @versioned_object = VersionedObject.new(:uid => uid,
                                            :owner_id => owner_id,
                                            :time_created => time_created,
                                            :all_versions => all_versions)
  end

  it 'should be an instance of VersionedObject' do
    @versioned_object.should be_an_instance_of VersionedObject
  end

  it 'uid value should be STU::VWX::5' do
    @versioned_object.uid.value.should == 'STU::VWX::5'
  end

  it 'owner_id namespace should be test' do
    @versioned_object.owner_id.namespace.should == 'test'
  end

  it 'all_versions.size should be 3' do
    @versioned_object.all_versions.size.should == 3
  end

  it 'version_count should be 3' do
    @versioned_object.version_count.should == 3
  end

  it 'time_created should equal 2009-11-09T09:53:22' do
    @versioned_object.time_created.value.should == '2009-11-09T09:53:22'
  end

  it 'all_version_ids should return all ids of versions' do
    ids = @versioned_object.all_version_ids
    ids.each do |id|
      %w(ABC::DEF::1 GHI::JKL::2 MNO::PQR::3).should include id.value
    end
  end

  it 'should have version id ABC::DEF::1' do
    object_version_id = ObjectVersionID.new(:value => 'ABC::DEF::1')
    @versioned_object.has_version_id?(object_version_id).should be_true
  end

  it 'should not have version id BCD::EFG::12' do
    object_version_id = ObjectVersionID.new(:value => 'BCD::EFG::12')
    @versioned_object.has_version_id?(object_version_id).should be_false
  end

  it 'ABC::DEF::1 should not be original version' do
    object_version_id = ObjectVersionID.new(:value => 'ABC::DEF::1')
    @versioned_object.is_original_version?(object_version_id).should be_false
  end

  it 'GHI::JKL::2 should be original version' do
    object_version_id = ObjectVersionID.new(:value => 'GHI::JKL::2')
    @versioned_object.is_original_version?(object_version_id).should be_true
  end

  it 'should have 2009-07-15T09:24:26 committed version' do
    exist_time = DvDateTime.new(:value => '2009-07-15T09:24:26')
    @versioned_object.has_version_at_time?(exist_time).should be_true
  end

  it 'should retrun version3 with id MNO::PQR::3' do
    uid = ObjectVersionID.new(:value => 'MNO::PQR::3')
    @versioned_object.version_with_id(uid).commit_audit.time_committed.
      should == DvDateTime.new(:value => '2009-07-15T09:24:26')
  end

  it 'should return version2 with 2008-12-12T19:32:14' do
    exist_date = DvDateTime.new(:value => '2008-12-12T19:32:14')
    @versioned_object.version_at_time(exist_date).lifecycle_state.
      defining_code.code_string.should == '553'
  end

  it 'latest_version should return version3' do
    @versioned_object.latest_version.uid.value.should == 'MNO::PQR::3'
  end

  it 'latest_trunk_version should return ABC::DEF::1' do
    @versioned_object.latest_trunk_version.uid.value.should ==
      'ABC::DEF::1'
  end

  it 'trunk_lifecycle_state should return 532' do
    @versioned_object.trunk_lifecycle_state.defining_code.
      code_string.should == '532'
  end

  it 'revision_history items are 3' do
    @versioned_object.revision_history.items.size.should == 3
  end

  it 'should be able to commit original version' do
    contribution = stub(ObjectRef, :empty? => false, :type => 'CONTRIBUTION')
    uid = ObjectVersionID.new(:value => 'EFG::HIJ::7')
    preceding_version_uid = ObjectVersionID.new(:value => 'ABC::DEF::1')
    audit = stub(AuditDetails)
    defining_code = stub(CodePhrase, :code_string => '523')
    lifecycle_state = stub(DvCodedText, :defining_code => defining_code)
    attestations = stub(Array, :empty? => false)
    @versioned_object.
      commit_original_version(:contribution => contribution,
                              :uid => uid,
                              :preceding_version_uid => preceding_version_uid,
                              :commit_audit => audit,
                              :lifecycle_state => lifecycle_state,
                              :data => 'data',
                              :attestations => attestations,
                              :signature => 'A41bdad')
    @versioned_object.all_versions.size.should == 4
  end

  it 'should raise ArgumentError with invalid preceeding version' do
    contribution = stub(ObjectRef, :empty? => false, :type => 'CONTRIBUTION')
    uid = ObjectVersionID.new(:value => 'EFG::HIJ::7')
    preceding_version_uid = ObjectVersionID.new(:value => 'BCD::EFG::8')
    audit = stub(AuditDetails)
    defining_code = stub(CodePhrase, :code_string => '523')
    lifecycle_state = stub(DvCodedText, :defining_code => defining_code)
    attestations = stub(Array, :empty? => false)
    lambda {
      @versioned_object.
      commit_original_version(:contribution => contribution,
                              :uid => uid,
                              :preceding_version_uid => preceding_version_uid,
                              :commit_audit => audit,
                              :lifecycle_state => lifecycle_state,
                              :data => 'data',
                              :attestations => attestations,
                              :signature => 'A41bdad')
    }.should raise_error ArgumentError
  end

  it 'should be able to commit original merged version' do
    contribution = stub(ObjectRef, :empty? => false, :type => 'CONTRIBUTION')
    uid = ObjectVersionID.new(:value => 'KLM::NOP::9')
    preceding_version_uid = ObjectVersionID.new(:value => 'ABC::DEF::1')
    time_committed = DvDateTime.new(:value => '2009-11-09T23:42:18')
    audit = stub(AuditDetails, :time_committed => time_committed)
    defining_code = stub(CodePhrase, :code_string => '523')
    lifecycle_state = stub(DvCodedText, :defining_code => defining_code)
    attestations = stub(Array, :empty? => false)
    @versioned_object.
      commit_original_merged_version(:contribution => contribution,
                              :uid => uid,
                              :preceding_version_uid => preceding_version_uid,
                              :commit_audit => audit,
                              :lifecycle_state => lifecycle_state,
                              :data => 'merged data',
                              :attestations => attestations,
                              :signature => 'dc3dbdad')
    @versioned_object.latest_version.data.should == 'merged data'
  end

  it 'should be able to commit imported_version' do
    contribution = stub(ObjectRef, :empty? => false, :type => 'CONTRIBUTION')
    time_committed = DvDateTime.new(:value => '2009-11-09T23:42:18')
    audit = stub(AuditDetails, :time_committed => time_committed)
    uid = ObjectVersionID.new(:value => 'QRS::TUV::10')
    preceding_version_uid = ObjectVersionID.new(:value => 'ABC::DEF::1')
    defining_code = stub(CodePhrase, :code_string => '523')
    lifecycle_state = stub(DvCodedText, :defining_code => defining_code)
    attestations = stub(Array, :empty? => false)
    original_version = OriginalVersion.new(:uid => uid,
                            :contribution => contribution,
                            :commit_audit => audit,
                            :preceding_version_uid => preceding_version_uid,
                            :data => 'original data',
                            :lifecycle_state => lifecycle_state,
                            :attestations => attestations)
    @versioned_object.commit_imported_version(:contribution => contribution,
                                              :commit_audit => audit,
                                              :item => original_version)
    @versioned_object.latest_version.commit_audit.time_committed.value.
      should == '2009-11-09T23:42:18'
  end

  it 'should be able to commit attestation' do
    attestation = stub(Attestation)
    uid = ObjectVersionID.new(:value => 'GHI::JKL::2')
    @versioned_object.commit_attestation(:attestation => attestation,
                                         :uid => uid,
                                         :signature => 'CDAEbad')
    @versioned_object.version_with_id(uid).signature.
      should == 'CDAEbad'
  end

  it 'should raise ArgumentError when time_created is nil' do
    lambda {
      @versioned_object.time_created = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when all_versions are nil' do
    lambda {
      @versioned_object.all_versions = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when is_original_version argument is nil' do
    lambda {
      @versioned_object.is_original_version?(nil)
    }.should raise_error ArgumentError
  end

  it 'should not has time data' do
    unexisted_time = DvDateTime.new(:value => '2009-11-10T00:43:59')
    lambda {
      @versioned_object.version_at_time(unexisted_time)
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil argument to commit_attestations' do
    lambda {
      @versioned_object.commit_attestation(:attestation => nil)
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with not orinigal version id' do
    uid = ObjectVersionID.new(:value => 'ABC::DEF::1')
    attestation = stub(Attestation)
    lambda {
      @versioned_object.commit_attestation(:attestation => attestation,
                                           :uid => uid,
                                           :signature => 'DEADBEAFE81')
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil argument to version with id' do
    lambda {
      @versioned_object.version_with_id(nil)
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with unexsited version with id ' do
    uid = ObjectVersionID.new(:value => 'CBA::FED::1')
    lambda {
      @versioned_object.version_with_id(uid)
    }.should raise_error ArgumentError
  end
end
