# ticket 192
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/am/openehr_profile/data_types/basic'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Basic
include ::OpenEHR::AssumedLibraryTypes

describe CDvState do
  before(:each) do
    proposed_state = State.new(:name => 'PROPOSED')
    complete_state = TerminalState.new(:name => 'COMPLETED')
    finish = Transition.new(:event => 'finish', :next_state => complete_state)
    transitions = Set[finish]
    non_terminal_state = NonTerminalState.new(:name => 'IN_EXECUTION',
                                              :transitions => transitions)
    states = Set[proposed_state, non_terminal_state, complete_state]
    state_machine = StateMachine.new(:states => states)
    occurrences = Interval.new(:upper => 1, :lower => 1)
    @c_dv_state = CDvState.new(:value => state_machine, :path => '/',
                               :occurrences => occurrences)
  end

  it 'is an instance of StateMachine' do
    expect(@c_dv_state).to be_an_instance_of CDvState
  end

  it 'states size should be 3' do
    expect(@c_dv_state.value.states.size).to be 3
  end

  it 'raise error if value is nil' do
    expect {@c_dv_state.value = nil}.to raise_error ArgumentError
  end

  describe '#valid_value?' do
    it 'is true for a DV_STATE naming a non-terminal state, is_terminal matching' do
      rm_state = OpenEHR::RM::DataTypes::Basic::DvState.new(:value => 'PROPOSED', :is_terminal => false)
      expect(@c_dv_state.valid_value?(rm_state)).to be true
    end

    it 'is true for a DV_STATE naming the terminal state, is_terminal matching' do
      rm_state = OpenEHR::RM::DataTypes::Basic::DvState.new(:value => 'COMPLETED', :is_terminal => true)
      expect(@c_dv_state.valid_value?(rm_state)).to be true
    end

    it 'is false when the state name is not in the state machine' do
      rm_state = OpenEHR::RM::DataTypes::Basic::DvState.new(:value => 'UNKNOWN', :is_terminal => false)
      expect(@c_dv_state.valid_value?(rm_state)).to be false
    end

    it 'is false when is_terminal disagrees with the named state' do
      rm_state = OpenEHR::RM::DataTypes::Basic::DvState.new(:value => 'PROPOSED', :is_terminal => true)
      expect(@c_dv_state.valid_value?(rm_state)).to be false
    end

    it 'accepts a code phrase value carrying the state name' do
      code = double(:code_string => 'PROPOSED')
      rm_state = OpenEHR::RM::DataTypes::Basic::DvState.new(:value => code, :is_terminal => false)
      expect(@c_dv_state.valid_value?(rm_state)).to be true
    end
  end
end
