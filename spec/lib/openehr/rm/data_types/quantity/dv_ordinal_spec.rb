require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification

describe DvOrdinal do
  before(:each) do
    terminology_id = stub(TerminologyID, :value => 'urine:prot')
    code_phrase = stub(CodePhrase, :terminology_id => terminology_id)
    symbol = stub(DvCodedText, :code_string => '+',
                  :defining_code => code_phrase)
    dv_text = stub(DvText, :value => 'limits')
    limits = stub(ReferenceRange, :meaning => dv_text)
    @dv_ordinal = DvOrdinal.new(:value => 1,
                                :symbol => symbol,
                                :limits => limits)
  end

  it 'should be an instance of DvOrdinal' do
    @dv_ordinal.should be_an_instance_of DvOrdinal
  end

  it 's value should be equal 1' do
    @dv_ordinal.value.should be_equal 1
  end

  it 's symbol should be + code string' do
    @dv_ordinal.symbol.code_string.should == '+'
  end

  it 's symbol defining_code should be urine:prot' do
    @dv_ordinal.symbol.defining_code.terminology_id.value.should ==
      'urine:prot'
  end

  it 'should be strictry comperable to other DvOrdinal' do
    terminology_id = stub(TerminologyID, :value => 'urine:prot')
    code_phrase = stub(CodePhrase, :terminology_id => terminology_id)
    symbol = stub(DvCodedText, :defining_code => code_phrase)
    dv_ordinal = DvOrdinal.new(:value => 2,
                               :symbol => symbol)
    @dv_ordinal.is_strictly_comparable_to?(dv_ordinal).should be_true
  end

  it 's limit.value should be limits' do
    @dv_ordinal.limits.meaning.value.should == 'limits'
  end

  it 'should raise error when limits.value is not limitted' do
    unlimit = stub(DvText, :value => 'unimitted')
    unlimitted_range = stub(ReferenceRange, :meaning => unlimit)
    lambda {
      @dv_ordinal.limits = unlimitted_range
    }.should raise_error ArgumentError
  end

  it 'should be comparable' do
    dv_ordinal = stub(DvOrdinal, :value => 2)
    @dv_ordinal.should < dv_ordinal
  end

  it 'is_strictly comparable should be false with other instance' do
    @dv_ordinal.is_strictly_comparable_to?('dummy').should be_false
  end

  it 'is strictly comparable should be false with other terminology' do
    terminology_id = stub(TerminologyID, :value => 'blood pressure')
    code_phrase = stub(CodePhrase, :terminology_id => terminology_id)
    symbol = stub(DvCodedText, :defining_code => code_phrase)
    dv_ordinal = DvOrdinal.new(:value => 3,
                               :symbol => symbol)
    @dv_ordinal.is_strictly_comparable_to?(dv_ordinal).should be_false
  end
end
