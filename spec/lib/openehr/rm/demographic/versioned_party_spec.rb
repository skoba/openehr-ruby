require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Demographic
include OpenEHR::RM::Common::ChangeControl
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification

describe VersionedParty do
  before(:each) do
    uid = HierObjectID.new(:value => 'STU::VWX::5')
    owner_id = double(ObjectRef, :namespace => 'test')
    time_created = DvDateTime.new(:value => '2009-11-09T09:53:22')
    object_version_uid = ObjectVersionID.new(:value => 'ABC::DEF::1')
    defining_code = double(CodePhrase, :code_string => '532')
    lifecycle_state = double(DvCodedText, :defining_code => defining_code)
    commit_audit = double(AuditDetails, :time_committed => time_created)
    version = double(Version, :commit_audit => commit_audit,
                     :lifecycle_state => lifecycle_state,
                     :uid => object_version_uid)
    @versioned_party = VersionedParty.new(:uid => uid,
                                          :owner_id => owner_id,
                                          :time_created => time_created,
                                          :all_versions => [version])
  end

  it 'should be an instance of VersionedParty' do
    expect(@versioned_party).to be_an_instance_of VersionedParty
  end

  it 'should be a VersionedObject (VERSIONED_PARTY inherits VERSIONED_OBJECT<PARTY> per spec)' do
    expect(@versioned_party).to be_a VersionedObject
  end

  it 'uid should be assigned properly' do
    expect(@versioned_party.uid.value).to eq('STU::VWX::5')
  end

  it 'latest_version should return the single version' do
    expect(@versioned_party.latest_version.uid.value).to eq('ABC::DEF::1')
  end
end
