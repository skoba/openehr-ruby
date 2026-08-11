require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification

describe DvScale do
  before(:each) do
    terminology_id = double(TerminologyID, :value => 'local')
    code_phrase = double(CodePhrase, :terminology_id => terminology_id)
    symbol = double(DvCodedText, :code_string => 'very_slight',
                  :defining_code => code_phrase)
    @dv_scale = DvScale.new(:value => 0.5, :symbol => symbol)
  end

  it 'should be an instance of DvScale' do
    expect(@dv_scale).to be_an_instance_of DvScale
  end

  it 'is a DvOrdered' do
    expect(@dv_scale).to be_a DvOrdered
  end

  it 's value should be equal 0.5' do
    expect(@dv_scale.value).to eq(0.5)
  end

  it 's symbol should be very_slight code string' do
    expect(@dv_scale.symbol.code_string).to eq('very_slight')
  end

  it 'should raise ArgumentError when value is nil' do
    expect {
      DvScale.new(:value => nil, :symbol => @dv_scale.symbol)
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when value is not a Real (Numeric)' do
    expect {
      DvScale.new(:value => 'not a number', :symbol => @dv_scale.symbol)
    }.to raise_error ArgumentError
  end

  it 'accepts an Integer value too (Real includes whole numbers)' do
    dv_scale = DvScale.new(:value => 3, :symbol => @dv_scale.symbol)
    expect(dv_scale.value).to eq(3)
  end

  it 'should raise ArgumentError when symbol is nil' do
    expect {
      DvScale.new(:value => 1.0, :symbol => nil)
    }.to raise_error ArgumentError
  end

  it 'should be comparable by value' do
    higher = double(DvScale, :value => 3.0)
    expect(@dv_scale).to be < higher
  end

  it 'should be strictly comparable to another DvScale with the same terminology' do
    terminology_id = double(TerminologyID, :value => 'local')
    code_phrase = double(CodePhrase, :terminology_id => terminology_id)
    symbol = double(DvCodedText, :defining_code => code_phrase)
    other = DvScale.new(:value => 1.0, :symbol => symbol)
    expect(@dv_scale.is_strictly_comparable_to?(other)).to be_truthy
  end

  it 'is not strictly comparable to a value from another terminology' do
    terminology_id = double(TerminologyID, :value => 'other')
    code_phrase = double(CodePhrase, :terminology_id => terminology_id)
    symbol = double(DvCodedText, :defining_code => code_phrase)
    other = DvScale.new(:value => 1.0, :symbol => symbol)
    expect(@dv_scale.is_strictly_comparable_to?(other)).to be_falsey
  end

  it 'is not strictly comparable to a non-DvScale instance' do
    expect(@dv_scale.is_strictly_comparable_to?('dummy')).to be_falsey
  end
end
