require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Text

describe TermMapping do
  before(:each) do
    target_double = double(DvCodedText, :value => 'TEST')
    purpose_double = double(DvCodedText, :value => 'automated')
    @term_mapping = TermMapping.new(:target => target_double,
                                    :match => '=',
                                    :purpose => purpose_double)
  end

  it 'should means equivalent' do
    expect(@term_mapping).to be_equivalent
  end

  it 'should means narrower' do
    @term_mapping.match = '<'
    expect(@term_mapping).to be_narrower
  end

  it 'should means broader' do
    @term_mapping.match = '>'
    expect(@term_mapping).to be_broader
  end

  it 'should means unknown' do
    @term_mapping.match = '?'
    expect(@term_mapping).to be_unknown
  end

  it 'should be valid match code >' do
    expect(TermMapping.is_valid_mach_code?('>')).to be_truthy
  end

  it 'should be valid match code =' do
    expect(TermMapping.is_valid_mach_code?('=')).to be_truthy
  end

  it 'should be valid match code <' do
    expect(TermMapping.is_valid_mach_code?('<')).to be_truthy
  end

  it 'should be valid match code ?' do
    expect(TermMapping.is_valid_mach_code?('?')).to be_truthy
  end

  it 'should be not valid code /' do
    expect(TermMapping.is_valid_mach_code?('/')).not_to be_truthy
  end

  it 's purpose should == automated' do
    expect(@term_mapping.purpose.value).to eq('automated')
  end

  it 'should raise ArgumentError when match is not valid' do
    expect {@term_mapping.match = '/'}.to raise_error(ArgumentError)
  end
end
