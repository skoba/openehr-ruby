require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Text

describe TermMapping do
  before(:each) do
    target_stub = stub(DvCodedText, :value => 'TEST')
    purpose_stub = stub(DvCodedText, :value => 'automated')
    @term_mapping = TermMapping.new(:target => target_stub,
                                    :match => '=',
                                    :purpose => purpose_stub)
  end

  it 'should means equivalent' do
    @term_mapping.should be_equivalent
  end

  it 'should means narrower' do
    @term_mapping.match = '<'
    @term_mapping.should be_narrower
  end

  it 'should means broader' do
    @term_mapping.match = '>'
    @term_mapping.should be_broader
  end

  it 'should means unknown' do
    @term_mapping.match = '?'
    @term_mapping.should be_unknown
  end

  it 'should be valid match code >' do
    TermMapping.is_valid_mach_code?('>').should be_true
  end

  it 'should be valid match code =' do
    TermMapping.is_valid_mach_code?('=').should be_true
  end

  it 'should be valid match code <' do
    TermMapping.is_valid_mach_code?('<').should be_true
  end

  it 'should be valid match code ?' do
    TermMapping.is_valid_mach_code?('?').should be_true
  end

  it 'should be not valid code /' do
    TermMapping.is_valid_mach_code?('/').should_not be_true
  end

  it 's purpose should == automated' do
    @term_mapping.purpose.value.should == 'automated'
  end

  it 'should raise ArgumentError when match is not valid' do
    lambda {@term_mapping.match = '/'}.should raise_error(ArgumentError)
  end
end
