$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
#require File.dirname(__FILE__) + '/shared_examples_spec'
include OpenEHR::RM::DataStructures::History
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::DataTypes::Text

describe Observation do
#  it_should_behave_like 'entry'
  let(:name) {DvText.new(:value => 'entry package')}
  let(:language) { double('language',:code_string => 'ja')}
  let(:encoding) { double('encoding', :code_string => 'UTF-8')}
  let(:subject) { double('PartyProxy')}

  before(:each) do
    data = stub(History, :archetype_node_id => 'at0002')
    state = stub(History, :archetype_node_id => 'at0003')
    @observation = Observation.new(:archetype_node_id => 'at0001',
                                   :name => name,
                                   :language => language,
                                   :encoding => encoding,
                                   :subject => subject,
                                   :data => data,
                                   :state => state)
  end

  it 'should be an instance of Observation' do
    @observation.should be_an_instance_of Observation
  end

  it 'data should be assigned properly' do
    @observation.data.archetype_node_id.should == 'at0002'
  end

  it 'should raise ArgumentError when nil assigned to data' do
    lambda {
      @observation.data = nil
    }.should raise_error ArgumentError
  end

  it 'state should be assigned properly' do
    @observation.state.archetype_node_id.should == 'at0003'
  end
end
