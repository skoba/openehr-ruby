require File.dirname(__FILE__) + '/../../../../../../spec_helper'
#require File.dirname(__FILE__) + '/shared_examples_spec'
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::Quantity::DateTime
include OpenEHR::RM::DataTypes::Encapsulated

describe Instruction do
#  it_should_behave_like 'entry'
  let(:name) {DvText.new(:value => 'entry package')}
  let(:language) { double('language',:code_string => 'ja')}
  let(:encoding) { double('encoding', :code_string => 'UTF-8')}
  let(:subject) { double('PartyProxy')}

  before(:each) do
    narrative = DvText.new(:value => 'instruction test')
    activities = double(Array, :size => 5, :empty? => false)
    expiry_time = DvDateTime.new(:value => '2009-11-18T20:58:34')
    wf_definition = double(DvParsable, :value => 'behavior driven')
    @instruction= Instruction.new(:archetype_node_id => 'at0001',
                                  :name => name,
                                  :language => language,
                                  :encoding => encoding,
                                  :subject => subject,
                                  :narrative => narrative,
                                  :activities => activities,
                                  :expiry_time => expiry_time,
                                  :wf_definition => wf_definition)
  end

  it 'should be an instance of Instruction' do
    expect(@instruction).to be_an_instance_of Instruction
  end

  it 'narrative should be assigned properly' do
    expect(@instruction.narrative.value).to eq('instruction test')
  end

  it 'should raise ArgumentError when narrative is assined with nil' do
    expect {
      @instruction.narrative = nil
    }.to raise_error ArgumentError
  end

  it 'activities should be assigned properly' do
    expect(@instruction.activities.size).to be_equal 5
  end

  it 'should raise ArgumentError with empty activities' do
    expect {
      @instruction.activities = [ ]
    }.to raise_error ArgumentError
  end

  it 'expiry_time should be assigned properly' do
    expect(@instruction.expiry_time.value).to eq('2009-11-18T20:58:34')
  end

  it 'wf_definition should be assigned properly' do
    expect(@instruction.wf_definition.value).to eq('behavior driven')
  end
end
