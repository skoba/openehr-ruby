require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Basic
include OpenEHR::RM::DataTypes::Text

describe DvIdentifier do
  before(:each) do
    @dv_identifier = DvIdentifier.new(:issuer => 'Ruby Hospital',
                                      :assigner => 'Information office',
                                      :id => '0123456-0',
                                      :type =>'personal id')
  end

  it 'should be an instance of DvIdentifier' do
    expect(@dv_identifier).to be_an_instance_of DvIdentifier
  end

  it 's issuer should be Ruby hospital' do
    expect(@dv_identifier.issuer).to eq('Ruby Hospital')
  end

  it 's assigner should be Information office' do
    expect(@dv_identifier.assigner).to eq('Information office')
  end

  it 's id should be 0123456-0' do
    expect(@dv_identifier.id).to eq('0123456-0')
  end

  it 's type should be personal id' do
    expect(@dv_identifier.type).to eq('personal id')
  end

  it 's issuer should be change to other hospital' do
    expect {
      @dv_identifier.issuer = 'Other Hospital'
    }.to change(@dv_identifier, :issuer).
      from('Ruby Hospital').to('Other Hospital')
  end

  it 'raise ArgumentError for nil issuer' do
    expect {
      @dv_identifier.issuer = nil
    }.to raise_error(ArgumentError)
  end

  it 'raise ArgumentError for empty issuer' do
    expect {
      @dv_identifier.issuer = ''
    }.to raise_error(ArgumentError)
  end

  it 's assigner should change from Information office to Service office' do
    expect {
      @dv_identifier.assigner = 'Service office'
    }.to change{@dv_identifier.assigner}.
      from('Information office').to('Service office')
  end

  it 'raise ArgumentError for nil assigner' do
    expect {
      @dv_identifier.assigner = nil
    }.to raise_error(ArgumentError)
  end

  it 'raise ArgumentError for empty assigner' do
    expect {
      @dv_identifier.assigner = ''
    }.to raise_error(ArgumentError)
  end

  it 's id should change from 0123456-0 to TEST-0987' do
    expect {
      @dv_identifier.id = 'TEST-0987'
    }.to change(@dv_identifier, :id).
      from('0123456-0').to('TEST-0987')
  end

  it 'raise ArgumentError for nil id' do
    expect {
      @dv_identifier.id = nil
    }.to raise_error(ArgumentError)
  end

  it 'raise ArgumentError for empty id' do
    expect {
      @dv_identifier.id = ''
    }.to raise_error(ArgumentError)
  end

  it 's type should change form personal id to test id' do
    expect {
      @dv_identifier.type = "test id"
    }.to change(@dv_identifier, :type).
      from('personal id').to('test id')
  end

  it 'raise ArgumentError for nil type' do
    expect {
      @dv_identifier.type = nil
    }.to raise_error(ArgumentError)
  end

  it 'raise ArgumentError for empty issuer' do
    expect {
      @dv_identifier.type = ''
    }.to raise_error(ArgumentError)
  end
end
