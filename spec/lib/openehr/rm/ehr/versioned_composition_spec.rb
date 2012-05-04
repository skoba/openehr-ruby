require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::EHR
include OpenEHR::RM::Composition
include OpenEHR::RM::Common::ChangeControl
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe VersionedComposition do
  before(:each) do
    composition1 = stub(Composition, :archetype_node_id => 'at0002',
                        :is_persistent? => true)
    version1 = stub(Version, :data => composition1)
    composition2 = stub(Composition, :archetype_node_id => 'at0002',
                        :is_persistent? => false)
    version2 = stub(Version, :data => composition2)
    uid = HierObjectID.new(:value => 'opeehr.jp::350')
    owner_id = stub(ObjectRef, :type => 'EHR')
    time_created = DvDateTime.new(:value => '2009-11-16T15:14:33')
    @versioned_composition = 
      VersionedComposition.new(:uid => uid,
                               :owner_id => owner_id,
                               :time_created => time_created,
                               :all_versions => [version1, version2])
  end

  it 'should be an instance of VersionedComposition' do
    @versioned_composition.should be_an_instance_of VersionedComposition
  end

  it 'is_persistent? should be evaluated by first version' do
    @versioned_composition.is_persistent?.should be_true
  end
end
