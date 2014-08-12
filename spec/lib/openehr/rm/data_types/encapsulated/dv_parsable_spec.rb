require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Encapsulated
include OpenEHR::RM::DataTypes::Text

describe DvParsable do
  before(:each) do
    @dv_parsable = DvParsable.new(:value => 'test',
                                  :formalism => 'plain/text')
  end

  it 'should be an instance of DvParsable' do
    expect(@dv_parsable).to be_an_instance_of DvParsable
  end

  it 'value should be test' do
    expect(@dv_parsable.value).to eq('test')
  end

  it 's size should be 4' do
    expect(@dv_parsable.size).to be_equal 4
  end

  it 's formalism should be plain/text' do
    expect(@dv_parsable.formalism).to eq('plain/text')
  end

  it 'should raise ArgumentError formalism nil' do
    expect {@dv_parsable.formalism = nil}.to raise_error(ArgumentError)
  end

  it 'should raise ArgumentError formalism empty' do
    expect {@dv_parsable.formalism = ''}.to raise_error(ArgumentError)
  end
end
