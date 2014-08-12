require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::Support::Identification

describe InstructionDetails do
  before(:each) do
    instruction_id = double(LocatableRef, :path => '[instruction]/[test]')
    wf_details = double(ItemStructure, :archetype_node_id => 'at0004')
    @instruction_details =
      InstructionDetails.new(:instruction_id => instruction_id,
                             :activity_id => 'at0003',
                             :wf_details => wf_details)
  end

  it 'should be an instance of InstructionDetails' do
    expect(@instruction_details).to be_an_instance_of InstructionDetails
  end

  it 'instruction_id should be assigned properly' do
    expect(@instruction_details.instruction_id.path).to eq(
      '[instruction]/[test]'
    )
  end

  it 'should raise ArgumentError with nil instruction_id' do
    expect {
      @instruction_details.instruction_id = nil
    }.to raise_error ArgumentError
  end

  it 'activity_id should be assigned properly' do
    expect(@instruction_details.activity_id).to eq('at0003')
  end

  it 'should raise ArgumentError with nil activity_id' do
    expect {
      @instruction_details.activity_id = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with empty activity_id' do
    expect {
      @instruction_details.activity_id = ''
    }.to raise_error ArgumentError
  end

  it 'wf_details should be assigned properly' do
    expect(@instruction_details.wf_details.archetype_node_id).to eq( 
      'at0004'
    )
  end
end
