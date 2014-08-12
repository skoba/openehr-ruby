require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
require 'openehr/rm/data_types/quantity'
include ::OpenEHR::RM::DataTypes::Quantity
include ::OpenEHR::RM::DataTypes::Text
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
end
