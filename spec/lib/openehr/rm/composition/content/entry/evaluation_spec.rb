require File.dirname(__FILE__) + '/../../../../../../spec_helper'
#require File.dirname(__FILE__) + '/shared_examples_spec'
include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::DataTypes::Text

describe Evaluation do
  let(:name) {DvText.new(:value => 'entry package')}
  let(:language) { double('language',:code_string => 'ja')}
  let(:encoding) { double('encoding', :code_string => 'UTF-8')}
  let(:subject) { double('PartyProxy')}
#  it_should_behave_like 'entry'

  before(:each) do
    data = double(ItemStructure, :archetype_node_id => 'at0002')
    @evaluation = Evaluation.new(:archetype_node_id => 'at0001',
                                 :name => name,
                                 :language => language,
                                 :encoding => encoding,
                                 :subject => subject,
                                 :data => data)
  end

  it 'should be an instance of Evaluation' do
    @evaluation.should be_an_instance_of Evaluation
  end

  it 'data should be properly assigned' do
    @evaluation.data.archetype_node_id.should == 'at0002'
  end

  it 'should raise ArgumentError when nil assigned to data' do
    lambda {
      @evaluation.data = nil
    }.should raise_error ArgumentError
  end
end
