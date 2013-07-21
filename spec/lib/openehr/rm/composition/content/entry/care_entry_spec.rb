require File.dirname(__FILE__) + '/../../../../../../spec_helper'
#require File.dirname(__FILE__) + '/shared_examples_spec'
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::Support::Identification

describe CareEntry do
  let(:language) { double('language',:code_string => 'ja')}
  let(:encoding) { double('encoding', :code_string => 'UTF-8')}
  let(:subject) { double('PartyProxy')}

  before(:each) do
    protocol = double(ItemStructure, :archetype_node_id => 'at0003')
    guideline_id = double(ObjectRef, :type => 'care guideline')
    @care_entry = CareEntry.new(:archetype_node_id => 'at0001',
                                :name => DvText.new(:value => 'care entry'),
                                :language => language,
                                :encoding => encoding,
                                :subject => subject,
                                :protocol => protocol,
                                :guideline_id => guideline_id)
  end

  it 'should be an instance of CareEntry' do
    @care_entry.should be_an_instance_of CareEntry
  end

  it 'protocol should be assigned properly' do
    @care_entry.protocol.archetype_node_id.should == 'at0003'
  end

  it 'guideline should be assined properly' do
    @care_entry.guideline_id.type.should == 'care guideline'
  end
end

