require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::Composition::Content::Entry
include OpenEHR::RM::DataTypes::Text

describe IsmTransition do
  before(:each) do
    current_state = double(DvCodedText, :value => 'planned')
    transition = double(DvCodedText, :value => 'scheduled')
    careflow_step = double(DvCodedText, :value => 'completed')
    @ism_transition = IsmTransition.new(:current_state => current_state,
                                        :transition => transition,
                                        :careflow_step => careflow_step)
  end

  it 'should be an instance of IsmTransition' do
    @ism_transition.should be_an_instance_of IsmTransition
  end

  it 'current_status should be assigned properly' do
    @ism_transition.current_state.value.should == 'planned'
  end

  it 'should raise ArgumentError with nil current state' do
    lambda {
      @ism_transition.current_state = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when current_state has invalid code'

  it 'transition should be assined properly' do
    @ism_transition.transition.value.should == 'scheduled'
  end

  it 'should raise ArgumentError with nil transition' do
    lambda {
      @ism_transition.transition = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArugmentError with invalid transition code'

  it 'careflow_step should be assigned properly' do
    @ism_transition.careflow_step.value.should == 'completed'
  end
end
