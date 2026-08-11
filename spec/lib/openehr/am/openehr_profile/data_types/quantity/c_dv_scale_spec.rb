require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
require 'openehr/rm/data_types/quantity'
include ::OpenEHR::RM::DataTypes::Quantity
include ::OpenEHR::RM::DataTypes::Text
include OpenEHR::AssumedLibraryTypes

describe CDvScale do
  before(:each) do
    occurrences = Interval.new(:upper => 1, :lower => 1)
    symbol = double(DvCodedText, :code_string => 'very_slight')
    list = [DvScale.new(:value => 0.5, :symbol => symbol)]
    @c_dv_scale = CDvScale.new(:list => list,
                               :path => 'value/scale',
                               :occurrences => occurrences,
                               :rm_type_name => 'DvScale')
  end

  it 'is an instance of CDvScale' do
    expect(@c_dv_scale).to be_an_instance_of CDvScale
  end

  it 'inherits DvDomain class, path is value/scale' do
    expect(@c_dv_scale.path).to eq('value/scale')
  end

  it '1st of list value is 0.5' do
    expect(@c_dv_scale.list[0].value).to eq(0.5)
  end

  it 'symbol code string is very_slight' do
    expect(@c_dv_scale.list[0].symbol.code_string).to eq('very_slight')
  end

  it 'list is empty then any_allowed is true' do
    @c_dv_scale.list = nil
    expect(@c_dv_scale).to be_any_allowed
  end

  describe '#valid_value?' do
    it 'is true for a value matching one of the list items' do
      symbol = double(DvCodedText, :code_string => 'very_slight')
      value = DvScale.new(:value => 0.5, :symbol => symbol)
      expect(@c_dv_scale.valid_value?(value)).to be true
    end

    it 'is false when the value does not match any list item' do
      symbol = double(DvCodedText, :code_string => 'very_slight')
      value = DvScale.new(:value => 1.0, :symbol => symbol)
      expect(@c_dv_scale.valid_value?(value)).to be false
    end

    it 'is false when the symbol differs even if the numeric value matches' do
      symbol = double(DvCodedText, :code_string => 'other')
      value = DvScale.new(:value => 0.5, :symbol => symbol)
      expect(@c_dv_scale.valid_value?(value)).to be false
    end

    it 'is true for any value when any_allowed' do
      @c_dv_scale.list = nil
      symbol = double(DvCodedText, :code_string => 'anything')
      value = DvScale.new(:value => 42.0, :symbol => symbol)
      expect(@c_dv_scale.valid_value?(value)).to be true
    end
  end
end
