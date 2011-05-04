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
    @dv_identifier.should be_an_instance_of DvIdentifier
  end

  it 's issuer should be Ruby hospital' do
    @dv_identifier.issuer.should == 'Ruby Hospital'
  end

  it 's assigner should be Information office' do
    @dv_identifier.assigner.should == 'Information office'
  end

  it 's id should be 0123456-0' do
    @dv_identifier.id.should == '0123456-0'
  end

  it 's type should be personal id' do
    @dv_identifier.type.should == 'personal id'
  end

  it 's issuer should be change to other hospital' do
    lambda {
      @dv_identifier.issuer = 'Other Hospital'
    }.should change(@dv_identifier, :issuer).
      from('Ruby Hospital').to('Other Hospital')
  end

  it 'raise ArgumentError for nil issuer' do
    lambda {
      @dv_identifier.issuer = nil
    }.should raise_error(ArgumentError)
  end

  it 'raise ArgumentError for empty issuer' do
    lambda {
      @dv_identifier.issuer = ''
    }.should raise_error(ArgumentError)
  end

  it 's assigner should change from Information office to Service office' do
    lambda {
      @dv_identifier.assigner = 'Service office'
    }.should change{@dv_identifier.assigner}.
      from('Information office').to('Service office')
  end

  it 'raise ArgumentError for nil assigner' do
    lambda {
      @dv_identifier.assigner = nil
    }.should raise_error(ArgumentError)
  end

  it 'raise ArgumentError for empty assigner' do
    lambda {
      @dv_identifier.assigner = ''
    }.should raise_error(ArgumentError)
  end

  it 's id should change from 0123456-0 to TEST-0987' do
    lambda {
      @dv_identifier.id = 'TEST-0987'
    }.should change(@dv_identifier, :id).
      from('0123456-0').to('TEST-0987')
  end

  it 'raise ArgumentError for nil id' do
    lambda {
      @dv_identifier.id = nil
    }.should raise_error(ArgumentError)
  end

  it 'raise ArgumentError for empty id' do
    lambda {
      @dv_identifier.id = ''
    }.should raise_error(ArgumentError)
  end

  it 's type should change form personal id to test id' do
    lambda {
      @dv_identifier.type = "test id"
    }.should change(@dv_identifier, :type).
      from('personal id').to('test id')
  end

  it 'raise ArgumentError for nil type' do
    lambda {
      @dv_identifier.type = nil
    }.should raise_error(ArgumentError)
  end

  it 'raise ArgumentError for empty issuer' do
    lambda {
      @dv_identifier.type = ''
    }.should raise_error(ArgumentError)
  end
end
