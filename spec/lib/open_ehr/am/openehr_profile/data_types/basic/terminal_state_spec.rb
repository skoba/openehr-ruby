# ticket 196
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'open_ehr/am/openehr_profile/data_types/basic'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Basic

describe TerminalState do
  before(:all) do
    @terminal_state = TerminalState.new(:name => 'PROPOSED')
  end

  it 'is an instance of TerminalState' do
    @terminal_state.should be_an_instance_of TerminalState
  end

  it 'name is PROPOSED' do
    @terminal_state.name.should == 'PROPOSED'
  end
end
