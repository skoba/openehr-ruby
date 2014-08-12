require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Basic
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Text

describe DvState do
  before(:each) do
    @terminology_id = TerminologyID.new(:value => 'openher')
    code_phrase = CodePhrase.new(:code_string => '524',
                                 :terminology_id => @terminology_id)
    dv_coded_text = DvCodedText.new(:value => "initial",
                                    :defining_code => code_phrase)
    @dv_state = DvState.new(:value => dv_coded_text,
                            :is_terminal => false)
  end

  it 'should be an instance of DvState' do
    expect(@dv_state).to be_an_instance_of DvState
  end

  it 's value should be initial' do
    expect(@dv_state.value.value).to eq('initial')
  end

  it 'should change other value assigned' do
    code_phrase = CodePhrase.new(:code_string => '526',
                                 :terminology_id => @terminology_id)
    dv_coded_text = DvCodedText.new(:value =>'planned',
                                    :defining_code => code_phrase)
    expect {
      @dv_state.value = dv_coded_text
    }.to change{@dv_state.value.value}.from('initial').to('planned')
  end

  it 'is not terminal' do
    expect(@dv_state.is_terminal?).to be_falsey
  end

  it 'should not be terminal * another expression' do
    expect(@dv_state).not_to be_terminal
  end

  it 'should change to terminal' do
    expect {
      @dv_state.is_terminal = true
    }.to change(@dv_state, :is_terminal?).from(false).to(true)
  end
end
