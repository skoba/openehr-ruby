require File.dirname(__FILE__) + '/../../../../../../spec_helper'
#require File.dirname(__FILE__) + '/shared_examples_spec'
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Common::Generic
include OpenEHR::RM::DataStructures::ItemStructure

describe AdminEntry do
  let(:name) {DvText.new(:value => 'entry package')}
  let(:language) { double('language',:code_string => 'ja')}
  let(:encoding) { double('encoding', :code_string => 'UTF-8')}
  let(:subject) { double('PartyProxy')}
#  it_should_behave_like 'entry'

  before(:each) do
    data = double(ItemStructure, :archetype_node_id => 'at0002')
    @admin_entry = AdminEntry.new(:archetype_node_id => 'at0001',
                                  :name => DvText.new(:value => 'admin entry'),
                                  :language => language,
                                  :encoding => encoding,
                                  :subject => subject,
                                  :data => data)
  end

  it 'should be an instance of AdminEntry' do
    expect(@admin_entry).to be_an_instance_of AdminEntry
  end

  it 'data should be assigned properly' do
    expect(@admin_entry.data.archetype_node_id).to eq('at0002')
  end

  it 'should raise ArgumentError when nil assigned to data' do
    expect {
      @admin_entry.data = nil
    }.to raise_error ArgumentError
  end
end
