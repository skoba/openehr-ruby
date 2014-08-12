require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Generic

describe Participation do
  before(:each) do
    performer = double(PartyProxy, :name => 'GEHIRN')
    function = double(DvText, :value => 'committer')
    mode = double(DvCodedText, :value => 'present')
    lower = double(DvDateTime, :value => '2009-10-03T20:33:05')
    time = double(DvInterval, :lower => lower)
    @participation = Participation.new(:performer => performer,
                                       :function => function,
                                       :mode => mode,
                                       :time => time)
  end

  it 'should be an instance of Participation' do
    expect(@participation).to be_an_instance_of Participation
  end

  it 'should assign performer properly' do
    expect(@participation.performer.name).to eq('GEHIRN')
  end

  it 'should assign function properly' do
    expect(@participation.function.value).to eq('committer')
  end

  it 'should assign mode properly' do
    expect(@participation.mode.value).to eq('present')
  end

  it 'should assign time properly' do
    expect(@participation.time.lower.value).to eq('2009-10-03T20:33:05')
  end
end
