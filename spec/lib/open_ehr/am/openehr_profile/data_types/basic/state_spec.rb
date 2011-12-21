# ticket 191
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'open_ehr/am/openehr_profile/data_types/basic'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Basic

describe State do
  before(:all) do
    @state = State.new(:name => 'PROPOSED')
  end

  it 'is an instance of State' do
    @state.should be_an_instance_of State
  end

  it 'name is PROPOSED' do
    @state.name.should == 'PROPOSED'
  end

  it 'raise error name is empty' do
    expect {@state.name = ''}.to raise_error
  end

  it 'raise error name is nil' do
    expect {@state.name = nil}.to raise_error
  end
end
