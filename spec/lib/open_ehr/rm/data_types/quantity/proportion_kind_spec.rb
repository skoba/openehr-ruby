require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe ProportionKind do
  it 'should be valid proportion kind 0' do
    ProportionKind.should be_valid_proportion_kind 0
  end

  it 'should be valid proportion kind 2' do
    ProportionKind.should be_valid_proportion_kind 2
  end

  it 'should be valid proportionkind 4' do
    ProportionKind.should be_valid_proportion_kind 4
  end

  it 'should not be valid proportionkind -1' do
    ProportionKind.should_not be_valid_proportion_kind -1
  end

  it 'should not be valid proportionkind 5' do
    ProportionKind.should_not be_valid_proportion_kind 5
  end
end
