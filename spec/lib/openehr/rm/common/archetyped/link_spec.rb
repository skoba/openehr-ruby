require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::Common::Archetyped
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::DataTypes::URI

describe Link do
  before(:each) do
    @link = Link.new(:meaning => DvText.new(:value => 'generic'),
                     :type => DvText.new(:value => 'problem'),
                     :target => DvEhrUri.new(:value => 'ehr://test'))
  end

  it 'should be an instance of Link' do
    expect(@link).to be_an_instance_of Link
  end

  it 'meaning should be generic' do
    expect(@link.meaning.value).to eq('generic')
  end

  it 'target should be ehr://test' do
    expect(@link.target.value).to eq('ehr://test')
  end

  it 'should raise ArgumentError with nil meaning' do
    expect {
      @link.meaning = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil type' do
    expect {
      @link.type = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with nil target' do
    expect {
      @link.target = nil
    }.to raise_error ArgumentError
  end
end
