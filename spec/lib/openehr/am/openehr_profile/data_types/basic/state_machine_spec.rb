# ticket 193
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/am/openehr_profile/data_types/basic'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Basic
require 'set'

describe StateMachine do
  before(:each) do
    proposed_state = State.new(:name => 'PROPOSED')
    complete_state = TerminalState.new(:name => 'COMPLETED')
    finish = Transition.new(:event => 'finish', :next_state => complete_state)
    transitions = Set[finish]
    non_terminal_state = NonTerminalState.new(:name => 'IN_EXECUTION',
                                              :transitions => transitions)
    states = Set[proposed_state, non_terminal_state, complete_state]
    @state_machine = StateMachine.new(:states => states)
  end

  it 'is an instance of StateMachine' do
    @state_machine.should be_an_instance_of StateMachine
  end

  it 'states size is 3' do
    @state_machine.states.size.should be 3
  end

  it 'raise error if states are nil' do
    expect {@state_machine.states = nil}.to raise_error
  end

  it 'raise error if states is empty' do
    expect {@state_machine.states = Set.new}.to raise_error
  end
end
