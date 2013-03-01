require File.dirname(__FILE__) + '/../../../../../spec_helper'
#require File.dirname(__FILE__) + '/shared_examples_spec'
require 'set'
include OpenEHR::RM::Common::ChangeControl
include OpenEHR::RM::DataTypes::Text

describe OriginalVersion do
#  it_should_behave_like 'change_control'

  before(:each) do
    uid = ObjectVersionID.new(:value => 'ABCD::EFG::2')
    preceding_version_uid = ObjectVersionID.new(:value => 'HIJ::KLM::1')
    commit_audit = stub(AuditDetails, :committer => 'UNKNOWN', :empty? => false)
    objectid = stub(ObjectID, :value => 'unique')
    contribution = ObjectRef.new(:namespace => 'local',
                                 :type => 'CONTRIBUTION',
                                 :id => objectid)
    defining_code = stub(CodePhrase, :code_string => '532')
    lifecycle_state = stub(DvCodedText, :defining_code => defining_code)
    signature = '4760271533c2866579dde347ad28dd79e4aad933'
    @version = Version.new(:uid => uid,
                           :preceding_version_uid => preceding_version_uid,
                           :data => 'data',
                           :contribution => contribution,
                           :lifecycle_state => lifecycle_state,
                           :commit_audit => commit_audit,
                           :signature => signature)
    attestations = stub(Array, :empty? => false, :size => 12)
    other_input_version_uids = stub(Set, :empty? => false, :size => 5)
    @original_version = OriginalVersion.new(:uid => uid,
                                            :lifecycle_state => lifecycle_state,
                                            :attestations => attestations,
                                            :commit_audit => commit_audit,
                                            :contribution => contribution,
                                            :other_input_version_uids => other_input_version_uids,
                                            :preceding_version_uid => preceding_version_uid)
  end

  it 'should be an isntance of OriginalVersion' do
    @original_version.should be_an_instance_of OriginalVersion
  end

  it 'attestation size should be 12' do
    @original_version.attestations.size.should == 12
  end

  it 'other_version_input_uids size should be 5' do
    @original_version.other_input_version_uids.size.should == 5
  end

  it 'is_merged? should be true when other_input_version_uids is nil' do
    @original_version.is_merged?.should be_true
  end

  it 'is_merged? should not be true when other_input_version_uids is not nil' do
    @original_version.other_input_version_uids = nil
    @original_version.is_merged?.should be_false
  end

  it 'should raise ArgumentError when attestations is empty' do
    lambda {
      @original_version.attestations = Set.new
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when other_input_version_uids is empty' do
    lambda {
      @original_version.other_input_version_uids = Set.new
    }.should raise_error ArgumentError
  end
end
