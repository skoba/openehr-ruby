require File.dirname(__FILE__) + '/../../../../../spec_helper'
#require File.dirname(__FILE__) + '/shared_examples_spec'
include OpenEHR::RM::Common::ChangeControl
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::DataTypes::Text

describe Version do
#  it_should_behave_like 'change_control'
  before(:each) do
    uid = ObjectVersionID.new(:value => 'ABCD::EFG::2')
    preceding_version_uid = ObjectVersionID.new(:value => 'HIJ::KLM::1')
    commit_audit = double(AuditDetails, :committer => 'UNKNOWN', :empty? => false)
    contribution = ObjectRef.new(:namespace => 'local',
                                 :type => 'CONTRIBUTION',
                                 :id => object_id)
    defining_code = double(CodePhrase, :code_string => '532')
    lifecycle_state = double(DvCodedText, :defining_code => defining_code)
    signature = '4760271533c2866579dde347ad28dd79e4aad933'
    @version = Version.new(:uid => uid,
                           :preceding_version_uid => preceding_version_uid,
                           :data => 'data',
                           :contribution => contribution,
                           :lifecycle_state => lifecycle_state,
                           :commit_audit => commit_audit,
                           :signature => signature)
  end


  it 'should be an instance of Version' do
    @version.should be_an_instance_of Version
  end

  it 'uid value should be ABCD::EFG::1' do
    @version.uid.value.should == 'ABCD::EFG::2'
  end

  it 'commit_audit.committer.should be UNKNOWN' do
    @version.commit_audit.committer.should == 'UNKNOWN'
  end

  it 'lifecycle_state should be 532' do
    @version.lifecycle_state.defining_code.code_string.should == '532'
  end

  it 'contribution namespece should be local' do
    @version.contribution.namespace.should == 'local'
  end

  it 'contribution type should be CONTRIBUTION' do
    contribution = @version.contribution
    contribution.type = 'PARTY'
    lambda {
      @version.contribution = contribution
    }.should raise_error ArgumentError
  end

  it 'signature should be 4760271533c2866579dde347ad28dd79e4aad933' do
    @version.signature.should == '4760271533c2866579dde347ad28dd79e4aad933'
  end

  it 'should not be a branch' do
    @version.is_branch?.should_not be true
  end

  it 'should be a branch' do
    @version.uid.value = 'ABCD::EFG::1.2.3'
    @version.is_branch?.should be true
  end

  it 'data should be data' do
    @version.data.should == 'data'
  end

  it 'owner_id value should be ABCD::EFG::2' do
    @version.owner_id.value.should == 'ABCD::EFG::2'
  end

  it 'canonical form is not well determined' do
    expect {
      @version.canonical_form
    }.to raise_error NotImplementedError
  end

  it 'should raise ArgumentError when preceding version id exists and uid version tree is first' do
    @version.uid.value = 'ABC::DEF::1'
    preceding_version_uid = ObjectVersionID.new(:value => 'GHI::JKL::2')
    expect {
      @version.preceding_version_uid = preceding_version_uid
    }.to raise_error ArgumentError
  end
end
