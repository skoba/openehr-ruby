# ticket 195
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'open_ehr/am/openehr_profile/data_types/basic'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Basic
require 'set'

describe NonTerminalState do
  before(:each) do
    proposed_state = State.new(:name => 'PROPOSED')
    complete_state = TerminalState.new(:name => 'COMPLETED')
    finish = Transition.new(:event => 'finish', :next_state => complete_state)
    transitions = Set[finish]
    @non_terminal_state = NonTerminalState.new(:name => 'IN_EXECUTION',
                                               :transitions => transitions)
  end

  it 'is an instance of NonTerminalState' do
    @non_terminal_state.should be_an_instance_of NonTerminalState
  end

  it 'name is IN_EXECUTION' do
    @non_terminal_state.name.should == 'IN_EXECUTION'
  end

  it 'size of transitions is 2' do
    @non_terminal_state.transitions.size.should == 1
  end

  it 'raise error if traisitions is empty' do
    expect {@non_terminal_state.transitions = Set.new}.to raise_error
  end

  it 'does not error if transitions is nil' do
    expect {@non_terminal_state.transitions = nil}.not_to raise_error
  end
end
