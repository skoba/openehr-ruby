# ticket 195
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/am/openehr_profile/data_types/basic'
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
    expect(@non_terminal_state).to be_an_instance_of NonTerminalState
  end

  it 'name is IN_EXECUTION' do
    expect(@non_terminal_state.name).to eq('IN_EXECUTION')
  end

  it 'size of transitions is 2' do
    expect(@non_terminal_state.transitions.size).to eq(1)
  end

  it 'raise error if traisitions is empty' do
    expect {@non_terminal_state.transitions = Set.new}.to raise_error
  end

  it 'raise error if transitions is nil' do
    expect {@non_terminal_state.transitions = nil}.to raise_error
  end
end
