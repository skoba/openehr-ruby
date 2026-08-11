require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::DataTypes::Text

describe IsmTransition do
  before(:each) do
    current_state = double(DvCodedText, :value => 'planned', :defining_code => double(CodePhrase, :code_string => '245'))
    transition = double(DvCodedText, :value => 'scheduled', :defining_code => double(CodePhrase, :code_string => '523'))
    careflow_step = double(DvCodedText, :value => 'completed')
    @ism_transition = IsmTransition.new(:current_state => current_state,
                                        :transition => transition,
                                        :careflow_step => careflow_step)
  end

  it 'should be an instance of IsmTransition' do
    expect(@ism_transition).to be_an_instance_of IsmTransition
  end

  it 'current_status should be assigned properly' do
    expect(@ism_transition.current_state.value).to eq('planned')
  end

  it 'should raise ArgumentError with nil current state' do
    expect {
      @ism_transition.current_state = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when current_state has invalid code' do
    strict_provider = Class.new do
      def has_code_for_group?(group_id, code)
        group_id == 'ism transition current state' && code == '245'
      end
    end.new
    OpenEHR::TerminologyService.provider = strict_provider
    invalid_state = double(DvCodedText, :defining_code => double(CodePhrase, :code_string => '999'))
    expect {
      @ism_transition.current_state = invalid_state
    }.to raise_error ArgumentError
    expect {
      @ism_transition.current_state = @ism_transition.current_state
    }.not_to raise_error
  ensure
    OpenEHR::TerminologyService.provider = nil
  end

  it 'transition should be assined properly' do
    expect(@ism_transition.transition.value).to eq('scheduled')
  end

  it 'should raise ArgumentError with nil transition' do
    expect {
      @ism_transition.transition = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArugmentError with invalid transition code' do
    strict_provider = Class.new do
      def has_code_for_group?(group_id, code)
        group_id == 'ism transition careflow transition' && code == '523'
      end
    end.new
    OpenEHR::TerminologyService.provider = strict_provider
    invalid_transition = double(DvCodedText, :defining_code => double(CodePhrase, :code_string => '999'))
    expect {
      @ism_transition.transition = invalid_transition
    }.to raise_error ArgumentError
    expect {
      @ism_transition.transition = @ism_transition.transition
    }.not_to raise_error
  ensure
    OpenEHR::TerminologyService.provider = nil
  end

  it 'careflow_step should be assigned properly' do
    expect(@ism_transition.careflow_step.value).to eq('completed')
  end
end
