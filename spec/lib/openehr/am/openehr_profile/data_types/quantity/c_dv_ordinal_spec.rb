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
    @c_dv_ordinal.should be_an_instance_of CDvOrdinal
  end

  it 'inherits DvDomain class, path is value/ordinal' do
    @c_dv_ordinal.path.should == 'value/ordinal'
  end

  it '1st of list valie is 1' do
    @c_dv_ordinal.list[0].value.should == 1
  end

  it 'symbol code string is AML' do
    @c_dv_ordinal.list[0].symbol.code_string.should == 'AML'
  end

  it 'list is empty then any_allowed is true' do
    @c_dv_ordinal.list = nil
    @c_dv_ordinal.should be_any_allowed
  end
end
