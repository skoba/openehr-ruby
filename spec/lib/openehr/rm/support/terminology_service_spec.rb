require File.dirname(__FILE__) + '/../../../../spec_helper'
include OpenEHR::RM::Support::Terminology

describe TerminologyService do
  before(:each) do
    @ts ||= TerminologyService.new
    @terminology_mock = mock('terminology')
  end

  it 'should get terminology by its name' do
  end

  it 'should get code_set by its name'

  it 'should reply if it has terminology or not'

  it 'should reply if it has terminology or not'

  it 'should reply all terminology_identifires'

  it 'should get openehr code stes'

  it 'should get code_set_identifiers'
end
