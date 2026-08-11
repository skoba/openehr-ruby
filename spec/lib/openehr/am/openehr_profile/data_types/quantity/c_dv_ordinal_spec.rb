require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
require 'openehr/rm/data_types/quantity'
include ::OpenEHR::RM::DataTypes::Quantity
include ::OpenEHR::RM::DataTypes::Text
include ::OpenEHR::RM::Support::Identification
include OpenEHR::AssumedLibraryTypes

describe CDvOrdinal do
  before(:each) do
    occurrences = Interval.new(:upper => 1, :lower => 1)
    symbol = double(DvCodedText, :code_string => 'AML')
    list = [DvOrdinal.new(:value => 1,:symbol => symbol)]
    @c_dv_ordinal = CDvOrdinal.new(:list => list,
                                   :path => 'value/ordinal',
                                   :occurrences => occurrences,
                                   :rm_type_name => 'DvOrdinal')

  end

  it 'is an instance of CDvOrdinal' do
    expect(@c_dv_ordinal).to be_an_instance_of CDvOrdinal
  end

  it 'inherits DvDomain class, path is value/ordinal' do
    expect(@c_dv_ordinal.path).to eq('value/ordinal')
  end

  it '1st of list valie is 1' do
    expect(@c_dv_ordinal.list[0].value).to eq(1)
  end

  it 'symbol code string is AML' do
    expect(@c_dv_ordinal.list[0].symbol.code_string).to eq('AML')
  end

  it 'list is empty then any_allowed is true' do
    @c_dv_ordinal.list = nil
    expect(@c_dv_ordinal).to be_any_allowed
  end

  describe '#valid_value?' do
    it 'is true for a value matching one of the list items' do
      symbol = double(DvCodedText, :code_string => 'AML')
      value = DvOrdinal.new(:value => 1, :symbol => symbol)
      expect(@c_dv_ordinal.valid_value?(value)).to be true
    end

    it 'is false when the value does not match any list item' do
      symbol = double(DvCodedText, :code_string => 'AML')
      value = DvOrdinal.new(:value => 2, :symbol => symbol)
      expect(@c_dv_ordinal.valid_value?(value)).to be false
    end

    it 'is false when the symbol differs even if the numeric value matches' do
      symbol = double(DvCodedText, :code_string => 'OTHER')
      value = DvOrdinal.new(:value => 1, :symbol => symbol)
      expect(@c_dv_ordinal.valid_value?(value)).to be false
    end

    it 'is true for any value when any_allowed' do
      @c_dv_ordinal.list = nil
      symbol = double(DvCodedText, :code_string => 'ANYTHING')
      value = DvOrdinal.new(:value => 42, :symbol => symbol)
      expect(@c_dv_ordinal.valid_value?(value)).to be true
    end

    it 'works against a real DvCodedText symbol, not just a double stubbing code_string directly' do
      defining_code = CodePhrase.new(:terminology_id => TerminologyID.new(:value => 'local'), :code_string => 'AML')
      real_symbol = DvCodedText.new(:value => 'AML', :defining_code => defining_code)
      value = DvOrdinal.new(:value => 1, :symbol => real_symbol)
      expect(@c_dv_ordinal.valid_value?(value)).to be true
    end
  end
end
