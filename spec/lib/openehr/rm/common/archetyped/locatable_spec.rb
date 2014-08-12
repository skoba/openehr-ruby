require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Archetyped
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification

describe Locatable do
  before(:each) do
    name = DvText.new(:value => 'problem/SOAP')
    link = double(Set, :size => 10, :empty? => false)
    uid = UIDBasedID.new(:value => 'ehr::localhost/3030')
    archetype_id = ArchetypeID.new(:value =>
                           'openEHR-EHR-SECTION.physical_examination.v2')
    archetype_details = double(Archetyped, :rm_version =>  '1.2.4',
                             :archetype_id => archetype_id)
    feeder_audit = double(FeederAudit, :system_id => 'MAGI')
    @locatable = Locatable.new(:archetype_node_id => 'at001',
                               :name => name,
                               :links => link,
                               :uid => uid,
                               :feeder_audit => feeder_audit,
                               :archetype_details => archetype_details)
  end

  it 'should be_an_instance_of Locatable' do
    expect(@locatable).to be_an_instance_of Locatable
  end

  it 'archetype_node_id should be at001' do
    expect(@locatable.archetype_node_id).to eq('at001')
  end

  it 'is_archetype_root? should be true' do
    expect(@locatable.is_archetype_root?).to be_truthy
  end

  it 'is_archetype_root? should be false when archetype_details is nil' do
    @locatable.archetype_details = nil
    expect(@locatable.is_archetype_root?).to be_falsey
  end

  it 'link size should be 10' do
    expect(@locatable.links.size).to eq(10)
  end

  it 'name.value should problem/soap' do
    expect(@locatable.name.value).to eq('problem/SOAP')
  end

  it 'uid.value should be ehr::localhost/3030' do
    expect(@locatable.uid.value).to eq('ehr::localhost/3030')
  end

  it 'archetype_details.rm_version should be 1.2.4' do
    expect(@locatable.archetype_details.rm_version).to eq('1.2.4')
  end

  it 'feeer_audit.system_id should MAGI' do
    expect(@locatable.feeder_audit.system_id).to eq('MAGI')
  end

  it 'concept should be physical_examination' do
    expect(@locatable.concept.value).to eq('physical_examination')
  end

  it 'should raise ArgumentError with nil archetype_node_id' do
    expect {
      @locatable.archetype_node_id = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil name' do
    expect {
      @locatable.name = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty links' do
    expect {
      @locatable.links = Set.new
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError Archetyped invalid' do
    @locatable.archetype_details = nil
    expect {
      @locatable.concept
    }.to raise_error ArgumentError
  end
end
