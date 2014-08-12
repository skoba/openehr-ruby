require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::EHR
include OpenEHR::RM::Composition
include OpenEHR::RM::Common::ChangeControl
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe VersionedComposition do
  before(:each) do
    composition1 = double(Composition, :archetype_node_id => 'at0002',
                        :is_persistent? => true)
    version1 = double(Version, :data => composition1)
    composition2 = double(Composition, :archetype_node_id => 'at0002',
                        :is_persistent? => false)
    version2 = double(Version, :data => composition2)
    uid = HierObjectID.new(:value => 'opeehr.jp::350')
    owner_id = double(ObjectRef, :type => 'EHR')
    time_created = DvDateTime.new(:value => '2009-11-16T15:14:33')
    @versioned_composition = 
      VersionedComposition.new(:uid => uid,
                               :owner_id => owner_id,
                               :time_created => time_created,
                               :all_versions => [version1, version2])
  end

  it 'should be an instance of VersionedComposition' do
    expect(@versioned_composition).to be_an_instance_of VersionedComposition
  end

  it 'is_persistent? should be evaluated by first version' do
    expect(@versioned_composition.is_persistent?).to be_truthy
  end
end
