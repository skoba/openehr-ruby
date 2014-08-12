# ticket 196
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/am/openehr_profile/data_types/basic'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Basic

describe TerminalState do
  before(:all) do
    @terminal_state = TerminalState.new(:name => 'PROPOSED')
  end

  it 'is an instance of TerminalState' do
    expect(@terminal_state).to be_an_instance_of TerminalState
  end

  it 'name is PROPOSED' do
    expect(@terminal_state.name).to eq('PROPOSED')
  end
end
