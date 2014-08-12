require File.dirname(__FILE__) + '/../../../../../../spec_helper'
#require File.dirname(__FILE__) + '/shared_examples_spec'
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataStructures::ItemStructure

describe Action do
  let(:name) {DvText.new(:value => 'entry package')}
  let(:language) { double('language',:code_string => 'ja')}
  let(:encoding) { double('encoding', :code_string => 'UTF-8')}
  let(:subject) { double('PartyProxy')}
#  it_should_behave_like 'entry'

  before(:each) do
    time = DvDateTime.new(:value => '2009-11-18T20:17:18')
    description = double(ItemStructure, :archetype_node_id => 'at0002')
    current_state = double(DvCodedText, :value => 'planned')
    ism_transition = double(IsmTransition, :current_state => current_state)
    instruction_details = double(InstructionDetails, :activity_id => 'at0003')
    @action= Action.new(:archetype_node_id => 'at0001',
                        :name => name,
                        :language => language,
                        :encoding => encoding,
                        :subject => subject,
                        :time => time,
                        :description => description,
                        :ism_transition => ism_transition,
                        :instruction_details => instruction_details)
  end

  it 'should be an instance of Action' do
    expect(@action).to be_an_instance_of Action
  end

  it 'time should be assigned properly' do
    expect(@action.time.value).to eq('2009-11-18T20:17:18')
  end

  it 'should raise ArgumentError with nil assigned to time' do
    expect {
      @action.time = nil
    }.to raise_error ArgumentError
  end

  it 'description should assigned properly' do
    expect(@action.description.archetype_node_id).to eq('at0002')
  end

  it 'should raise ArgumentError with nil description' do
    expect {
      @action.description = nil
    }.to raise_error ArgumentError
  end

  it 'ism_transition should be assigned properly' do
    expect(@action.ism_transition.current_state.value).to eq('planned')
  end

  it 'should raise ArgumentError with nil ism_transition' do
    expect {
      @action.ism_transition = nil
    }.to raise_error ArgumentError
  end

  it 'instruction_details should be assigned properly' do
    expect(@action.instruction_details.activity_id).to eq('at0003')
  end
end
